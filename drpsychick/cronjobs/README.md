## Cronjobs

### Setup multiple simple jobs
* You can use your own images, e.g. simple small task based images
* You can run simple shell commands out-of-the-box

`values.yaml`:
```yaml
jobs:
  - name: test1
    schedule: "*/5 * * * *"
    args:
      - "echo 'Job1'; sleep 5"
  - name: test2
    schedule: "*/30 * * * *"
    image:
      repository: alpine
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
* [ ] 