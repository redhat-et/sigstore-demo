#!/usr/bin/env bash

# Removes all Tekton PipelineRuns and TaskRuns
tkn pipelinerun delete --all -f
tkn taskrun delete --all -f

# Removes all images for the base image
for i in $(gcloud container images list-tags gcr.io/ifontlabs/ubi8-minimal --filter='tags:*'  --format="get(digest)" --limit=100); do
  gcloud container images delete --force-delete-tags --quiet gcr.io/ifontlabs/ubi8-minimal@${i}
done

# Make sure we're at the latest HEAD on the main branch
git fetch --all --prune
git merge --ff-only
