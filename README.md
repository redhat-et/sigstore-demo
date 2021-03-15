# sigstore-demo

## Setup

### Create Tekton Tasks and Pipeline

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
