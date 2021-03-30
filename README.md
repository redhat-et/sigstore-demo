# sigstore-demo

This contains the content used to demo sigstore at the OpenShift Commons Briefing on March 30, 2021; a recording of this can be found at [https://www.youtube.com/watch?v=yKrbUGSwrEw](https://www.youtube.com/watch?v=yKrbUGSwrEw).

Slides from the presentation can be seen at: [https://speakerdeck.com/redhatopenshift/secure-your-open-source-supply-chain-with-sigstore](https://speakerdeck.com/redhatopenshift/secure-your-open-source-supply-chain-with-sigstore).

## Setup

### Create Tekton Tasks

```shell
oc apply -f ./config/tekton/task
```

### Create Tekton Pipeline

```shell
oc apply -f ./config/tekton/pipeline
```

### Create Tekton Trigger

```shell
oc apply -f ./config/tekton/trigger
```

### Expose Tekton Event Listener Service

Once the `el-sigstore-demo-app` service has been created by Tekton, expose it
by running:

```shell
oc expose service el-sigstore-demo-app
```

### Add GitHub Webhook Manually

Open GitHub repo (Go to Settings > Webhooks) click on `Add webhook`. Under
Payload URL, paste the output of:

```shell
echo $(oc get route el-sigstore-demo-app --template='http://{{.spec.host}}')
```

Select Content type as `application/json`. Add secret eg: `sigstore`. Click on
`Add Webhook`.

### Test It

Now when we perform any push event on the repo, it will trigger the pipeline
with a new pipeline run. To test it, run:

```shell
git commit -m "empty-commit" --allow-empty && git push origin main
```
