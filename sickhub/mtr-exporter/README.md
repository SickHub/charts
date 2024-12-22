# mtr-exporter Helm Chart

A chart that lets you run an mtr-exporter to monitor routes.

## Deploy mtr-exporter

Configure `exporterJobs` in `values.yaml` to do MTRs regularly with given options to certain destinations.

```shell
helm repo add sickhub https://sickhub.github.io/charts
helm repo update
helm search repo sickhub
helm upgrade --create-namespace --namespace test --install --values values.yaml mtr-exporter sickhub/mtr-exporter
```

## Test locally

### Lint and template

```shell
(cd ..; ct lint --chart-dirs . --charts mtr-exporter)
helm template test . -f ci/test-values.yaml
```

### Test on local k8s
```shell
helm upgrade -i mtr-exporter . -f ci/test-values.yaml
```

## Credits
* Icon from [Smashicons](https://www.flaticon.com/authors/smashicons) found on [FlatIcon](https://www.flaticon.com/)
