## cronjobs Helm Chart
A chart that lets you setup one or multiple jobs with ease.

Components:
* Per job, one `busybox` (or your image) pod that runs at scheduled times
* Optional `configMap`s that contain your scripts

## Deploy cronjobs
```shell
helm repo add sickhub https://sickhub.github.io/charts
helm repo update
helm search repo sickhub
helm upgrade --create-namespace --namespace test --install --values values.yaml my-jobs sickhub/cronjobs
```

## Setup
### Setup multiple simple cronjobs
* You can use your own images, e.g. simple, small, task based images
* You can run simple shell commands out-of-the-box with `command` and `args`
* You can include small scripts through `configMap`s and run them on a generic image

`values.yaml`:
```yaml
jobs:
  job1:
    schedule: "*/5 * * * *"
    command: ["/bin/sh"]
    args:
      - "/configMaps/scripts/script.sh"
  curl-30-min:
    schedule: "*/30 * * * *"
    image:
      registry: docker.io
      repository: alpine
      tag: 3.13
    command:
      - "/bin/sh"
      - "-c"
    args:
      - "apk add --no-cache curl; curl -I https://google.com"
```

### ConfigMaps and Secrets for scripts and data
* mounted as `/configMaps/{{ name }}` and `/secrets/{{ name }}` respectively

#### Existing configMap
Use an existing configMap in your cronjobs, it will be available at `/configMaps/global-configmap/`
```yaml
customConfigMap: global-configmap
```

#### Files from strings
Hint: you can load larger files from separate `yaml` files.

Example: 
`helm template example cronjobs --debug --values cronjobs/ci/scripts-values.yaml,cronjobs/ci/config-test.yaml`

```yaml
configMaps:
  scripts:
    data:
      script.sh: |-
        #!/bin/sh
        echo "I am started in Job1"
        sleep 5
```

#### Files from files which are within the chart directory
Helm can access files, but only when they are within the chart directory, see https://helm.sh/docs/chart_template_guide/accessing_files/
```yaml
configMaps:
  from-files:
    files:
      example.sh: ci/files/example.sh

secrets:
  ssh-creds:
    files:
      id-rsa.pub: ci/files/id-rsa.pub
```


## Missing features - help appreciated
* [ ] allow overwriting `nodeSelector, affinity, resources, ...`
* [x] add support for scripts + secrets via `ConfigMap` and `Secret`
* [ ] add support for `volumes` + `volumeMounts`
* [ ] add some specific examples

## Contribute
* Create issues: Be specific. What do you expect? How do you suggest we get there?
* Create pull requests: Don't ask, just create a PR. Small improvements at a time please.
* See [Contributing](../../CONTRIBUTING.md)

### Testing
* Run chart-testing locally (requires `brew install chart-testing yamllint; pip3 install yamale`)
```shell
helm repo add common https://charts.bitnami.com/bitnami
ct lint --remote origin --chart-dirs=$PWD/sickhub --all
```
* Run chart-testing in docker
```shell
docker run --rm -it -v $PWD:/data quay.io/helmpack/chart-testing  bash -c \
  "helm repo add common https://charts.bitnami.com/bitnami; ct lint --remote origin --chart-dirs=/data/sickhub --all"
```

## Credits
* Cronjobs icon from  [Those Icons](https://www.flaticon.com/de/autoren/those-icons) found on  [FlatIcon](https://www.flaticon.com/)