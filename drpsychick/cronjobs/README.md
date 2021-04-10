## Cronjobs

### Setup multiple simple cronjobs
* You can use your own images, e.g. simple small task based images
* You can run simple shell commands out-of-the-box

`values.yaml`:
```yaml
jobs:
  - name: job1
    schedule: "*/5 * * * *"
    args:
      - "echo 'Job1'; sleep 5"
  - name: curl-30-min
    schedule: "*/30 * * * *"
    image:
      registry: docker.io
      repository: alpine
      tag: 3.13
    args:
      - "apk add --no-cache curl; curl -I https://google.com"
```

### Deploy jobs
```shell
helm repo add drpsychick https://drpsychick.github.io/charts
helm repo update
helm search repo drpsychick
helm upgrade --create-namespace --namespace test --install --values values.yaml jobs drpsychick/cronjobs
```

## TODO
* [ ] allow overwriting `nodeSelector, affinity, ...`
* [ ] add charts ci pipeline
* [ ] add support for `volumes` + `volumeMounts`
* [ ] add some specific examples

## Contribute
* Create issues: Be specific. What do you expect? How do you suggest we get there?
* Create pull requests: Don't ask, just create a PR. Small improvements at a time please.