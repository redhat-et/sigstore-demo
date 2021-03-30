#!/bin/sh
#set -x
#doitlive commentecho: true

# tested with OpenSSL, jq, and the Smallstep CLI (https://github.com/smallstep/cli).

# Step 1: Use Cosign to generated ephemeral keypair
# 
# create artifact to distribute
#
head -c 128 < /dev/urandom > artifact
#
# generate ephemeral keypair
#
openssl ecparam -genkey -name secp384r1 > ec_private.pem ; openssl ec -in ec_private.pem -pubout > ec_public.pem
# 
# sign using private key
# 
openssl dgst -sha256 -sign ec_private.pem artifact > artifact.sig
# 
# verify using public key
# 
openssl dgst -sha256 -verify ec_public.pem -signature artifact.sig artifact
# 
# use step to get ID token from Fulcio OIDC IdP (note this token only lasts 60 sec)
# 
./step oauth --provider=https://oauth2.sigstore.dev/auth --client-id=sigstore --listen localhost:0 --oidc --bare 2>/dev/null > id_token
# 
# extract email from ID token
# 
cat id_token | ./step crypto jwt inspect --insecure |jq -r .payload.email | tr -d '\n' > email; cat email
# 
# sign email address string with private key
# 
openssl dgst -sha256 -sign ec_private.pem email > email.sig
# 
# submit to fulcio via curl (need to sign email address with private key)
# 
curl -s https://fulcio-dev.sigstore.dev/api/v1/signingCert -H "Authorization: Bearer $(cat id_token)" -H "Accept: application/pem-certificate-chain" -H "Content-Type: application/json" -o signingCertChain.pem --data-binary "{ \"publicKey\": { \"algorithm\": \"ecdsa\", \"content\": \"$(./step crypto key format ec_public.pem|base64)\" }, \"signedEmailAddress\": \"$(cat email.sig|base64)\" }"
# 
# delete key pair as they are no longer needed
# 
rm -rf ec_private.pem ec_public.pem
# 
# inspect signing cert chain
# 
openssl crl2pkcs7 -nocrl -certfile signingCertChain.pem | openssl pkcs7 -print_certs -text -noout | less
# 
# submit signature for & signing cert to rekor
# 
./rekor-cli upload --artifact artifact --signature artifact.sig --public-key signingCertChain.pem --pki-format x509
# 
# verify that the entry is in the signature transparency log
# 
./rekor-cli verify --artifact artifact --signature artifact.sig --public-key signingCertChain.pem --pki-format x509
