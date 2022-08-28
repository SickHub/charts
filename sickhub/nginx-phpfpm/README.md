## nginx-phpfpm Helm Chart
A chart that lets you run a scalable nginx + phpfpm setup quickly.

Components
* 1+ `nginx` pod(s) that serve static files and forward `.php` requests to phpfpm
* 1+ `phpfpm` pod(s) that serve `.php` traffic

Both are independently scalable, the `nginx` pod forwards PHP traffic to the `phpfpm` pods through a service.

## Deploy nginx-phpfpm
```shell
helm repo add sickhub https://sickhub.github.io/charts
helm repo update
helm search repo sickhub
helm upgrade --create-namespace --namespace test --install --values values.yaml my-release sickhub/nginx-phpfpm
```

## Setup
For general guidance, see [values.yaml](values.yaml)

### Use `ingress` with `cert-manager`
Enable ingress, add `tls-acme` annotation and `hosts`/`tls` configuration
```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: "letsencrypt"
  hosts:
    - host: service.example.com
      paths: ["/"]
  tls:
    - secretName: service-tls
      hosts: ["service.example.com"]
```

### Nginx
* uses `/health.php` as an health endpoint by default (e.g. expects that to exist on the `phpfpm` image)
  * the path `/health.php` is only accessible from within the cluster.
* [ ] TODO: the `nginx.conf` can be provided in the `values.yaml`
* access can be restricted with simple basic auth through `nginx.htaccess`

### PHP FPM
You have multiple options to run your code:
* overwrite the chart PHP FPM version by setting `phpfpm.image.tag = "7.4-fpm-alpine"`
* create your own image which includes your app (recommended)
* use `persistence` to mount a PVC containing your app
* add simple scripts to your `values.yaml` to run on a generic image
  
Requirements:
* image must include `/health.php` used by health check of `nginx`

#### Use your own PHP FPM image
Create your own image including your code:
```dockerfile
FROM php:8-fpm-alpine

COPY app/* /var/www/html/

ENV SOME_ENVIRONMENT="" \
    PASSED_THROUGH_CHART=""
```
Then use the image and add the variables to the deployment
```yaml
phpfpm:
  image:
    registry: myregistry
    repository: myfpmimage
    tag: "latest"
  extraEnv:
    - name: SOME_ENVIRONMENT
      value: "This is my content"
```

#### Pass small scripts through `values.yaml`
```yaml
configMaps:
  scripts:
    path: /
    data:
      health.php: |
        <?php phpinfo(); ?>
  configs:
    path: /etc
    data:
      config.ini: |
        [global]
        mysetting = value
```

Each `configMap` will be created and made available to both the `nginx` and the `phpfpm` pods.

## Serving static files (Experimental)
By default, when `persistence` is disabled, you can simply provide a list of file or directory patterns,
to copy static files from the `phpfpm` image to the document root of `nginx` to serve them.
```yaml
phpfpm:
  staticFiles:
    - *.jpg
    - assets
```
This will add an `initContainer` to the `nginx` pod, executing
```shell
for f in {{ .Values.phpfpm.staticFiles | join " " }}; do cp -a {{ .Values.phpfpm.docRoot }}/$f /docRoot; done
```

### Persistence (Experimental)
If you don't want to use your own image, which contains everything for the application to run,
you can use `persistence.enabled = true` to
* A) let the chart create a PVC for you, bound to a volume named after the chart
* B) provide an `existingVolume` to use with a PVC created by the chart 
* C) provide an `existingClaim` to use an existing PVC

## Missing features - help appreciated
* [ ] provide `nginx.conf` through `values.yaml` -> make it configurable
* [ ] test scenarios and/or examples
  * [ ] test autoscaling
  * [ ] test persistence

## Contribute
* Create issues: Be specific. What do you expect? How do you suggest we get there?
* Create pull requests: Don't ask, just create a PR. Small improvements at a time please.
* See [Contributing](../../CONTRIBUTING.md) 

## Credits
* Icon from [Freepik](https://www.freepik.com) found on [FlatIcon](https://www.flaticon.com/)