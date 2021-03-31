#!/bin/sh
#set -x
#doitlive commentecho: true

# Requires openssl, step (https://github.com/smallstep/cli), jq

## COSIGN or SWISS-ARMY-KNIFE TOOL
  # use openssl to generate keypair
  openssl ecparam -genkey -name secp384r1 > ec_private.pem
  
  # show private key
  openssl pkcs8 -topk8 -in ec_private.pem -nocrypt
  
  # extract public key
  openssl ec -in ec_private.pem -pubout > ec_public.pem
  
  # show public key
  cat ec_public.pem

## FULCIO
  # use step to get ID token from Fulcio OIDC IdP (note this token only lasts 60 sec)
  ./step oauth --provider=https://oauth2.sigstore.dev/auth --client-id=sigstore --listen localhost:0 --oidc --bare 2>/dev/null > id_token
  
  # inspect OIDC ID token
  cat id_token | ./step crypto jwt inspect --insecure
  
  # extract email from ID token
  cat id_token | ./step crypto jwt inspect --insecure |jq -r .payload.email | tr -d '\n' > email
  
  # sign email address string with private key
  openssl dgst -sha256 -sign ec_private.pem email > email.sig
  
  # verify signature locally
  openssl dgst -sha256 -verify ec_public.pem -signature email.sig email

  # submit to fulcio via curl (need to sign email address with private key)
  curl -s https://fulcio-dev.sigstore.dev/api/v1/signingCert -H "Authorization: Bearer $(cat id_token)" -H "Accept: application/pem-certificate-chain" -H "Content-Type: application/json" -o signingCertChain.pem --data-binary "{ \"publicKey\": { \"algorithm\": \"ecdsa\", \"content\": \"$(./step crypto key format ec_public.pem|base64)\" }, \"signedEmailAddress\": \"$(cat email.sig|base64)\" }"
 
# inspect signing cert chain
openssl crl2pkcs7 -nocrl -certfile signingCertChain.pem | openssl pkcs7 -print_certs -text -noout

# verify signed email address using pub key in signing cert
openssl x509 -pubkey -noout -in signingCertChain.pem > signingPubKey.pem
openssl dgst -sha256 -verify signingPubKey.pem -signature email.sig email
diff signingPubKey.pem ec_public.pem || echo "pub key from signing cert does not match generated one"

## COSIGN or SWISS-ARMY-KNIFE TOOL
  # generate & sign artifact and generate detached signature
  head -c 128 < /dev/urandom > artifact
  openssl dgst -sha256 -sign ec_private.pem artifact > artifact.sig
  openssl dgst -sha256 -verify signingPubKey.pem -signature artifact.sig artifact

## REKOR
  # submit signature for & signing cert to rekor
  curl -s https://api.rekor.dev/api/v1/log/entries -H "Accept: application/json" -H "Content-Type: application/json" -o rekor_output --data-binary " { \"apiVersion\": \"0.0.1\", \"kind\": \"rekord\", \"spec\": { \"signature\": { \"format\": \"x509\", \"content\": \"$(cat artifact.sig|base64)\", \"publicKey\": { \"content\": \"$(cat signingCertChain.pem|base64)\" } }, \"data\": { \"content\": \"$(cat artifact|base64)\" } } }"
  jq '.[keys[0]].body |= (@base64d|fromjson)' rekor_output

  # print inclusion proof for entry
  curl -s -H "Accept: application/json" https://api.rekor.dev/api/v1/log/entries/$(jq -r -c 'keys[0]' rekor_output)/proof | jq .
  ./rekor-cli verify --artifact artifact --signature artifact.sig --public-key signingCertChain.pem --pki-format x509

# delete private key - since all we need to verify signature is stored in Rekor
rm -rf ec_private.pem