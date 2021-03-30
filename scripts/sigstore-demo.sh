#/usr/bin/env bash

# Recorded with the doitlive recorder
#doitlive shell: /bin/bash
#doitlive prompt: damoekri
#doitlive speed: 3
#doitlive env: COSIGN_EXPERIMENTAL=1
#doitlive commentecho: true

## DEMO THE RUNNING APP
google-chrome https://sigstore-demo-app.apps.sigstore-demo.bcallawa.dev/

# contents of repo
ls -tr

# list of maintainers
vi MAINTAINERS.json

## Dockerfile for running app
vi Dockerfile

## UNSIGNED CONTAINER IMAGE

# build base container image
podman build --no-cache -f config/image/base/Dockerfile . -t gcr.io/ifontlabs/ubi8-minimal:stable

# push base container image
podman push gcr.io/ifontlabs/ubi8-minimal:stable

# make change to app
vi main.go

# commit change
git commit -a -m "Update Hello World message"

# push change
git push

# pipelinerun

## SIGNED CONTAINER IMAGE

# sign existing container image
cosign sign gcr.io/ifontlabs/ubi8-minimal:stable

# re-run pipeline and deploy app changes

## STOLEN CREDENTIALS

# Dockerfile for malicious image
cat config/image/base/exploit/Dockerfile

# build malicious image
podman build --no-cache -f config/image/base/exploit/Dockerfile . -t gcr.io/ifontlabs/ubi8-minimal:stable

# push malicious image
podman push gcr.io/ifontlabs/ubi8-minimal:stable

# sign malicious image
cosign sign gcr.io/ifontlabs/ubi8-minimal:stable

# make another change to app
vi main.go

# commit change
git commit -a -m "Update Hello World message again"

# push change
git push


