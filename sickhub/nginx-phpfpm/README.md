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
* uses `/healthz.php` and `/livez.html` as an readiness and liveness probes by default (e.g. expects that to exist on the `phpfpm` image)
  * the path `/healthz.php` is only accessible from within the cluster.
* [ ] TODO: the `nginx.conf` can be provided in the `values.yaml`
* access can be restricted with simple basic auth through `nginx.htaccess`

### PHP FPM
You have multiple options to run your code:
* overwrite the chart PHP FPM version by setting `phpfpm.image.tag = "7.4-fpm-alpine"`
* create your own image which includes your app (recommended)
* use `persistence` to mount a PVC containing your app
* add simple scripts to your `values.yaml` to run on a generic image
  
Requirements:
* image must include `/healthz.php` and `/livez.html` used by probes of `nginx`.
* add `/livez.html` to `phpfpm.staticFiles` so that it is copied to the nginx docroot.

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
      livez.html: |
        <html><body>OK</body></html>
      healthz.php: |
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
    - livez.html
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

## Load testing
Install the Chart with `loadtest-values.yaml` which includes a few simple scripts (endpoints), one of which causes
the PHP process to consume all available CPU for a few seconds.
```shell
helm upgrade --install load-test sickhub/nginx-phpfpm --values sickhub/nginx-phpfpm/ci/loadtest-values.yaml
```

### Run tests with `wrk`
- `-d 10s` test duration
- `-t 20` number of threads
- `-c 20` number of connections to keep open (must be >= threads)
```shell
wrk -d 10s -t 50 -c 50 http://localhost/healthz.php # 10 seconds, 50 threads, 100 connections
wrk -d 10s -t 5 -c 10 http://localhost/livez.html # static HTML page from Nginx
wrk -d 10s -t 20 -c 40 http://localhost/healthz.php # phpinfo from PHP container
wrk -d 10s -t 5 -c 10 http://localhost/load.php # 100% load for X seconds, then return phpinfo
```

Run test suite:
- 3 threads which cause load
- 50 threads requesting PHP
- 10 threads requesting static HTML 
```shell
export time=300s
wrk -d $time -t 3 -c 3 http://localhost/load.php &
sleep 1
wrk -d $time -t 50 -c 100 http://localhost/healthz.php &
sleep 1
wrk -d $time -t 10 -c 100 http://localhost/livez.html &
```

You will notice, that with the right `shutdownDelay` and deployment `strategy`, you can get your installation to do
an update without dropping a single request (100% availability while doing a rollingUpdate).

While running the test suite, simply apply a small change via helm (memory limits for example) and watch the pods being
created and gracefully terminated without missing a request.

See also: https://medium.com/inside-personio/graceful-shutdown-of-fpm-and-nginx-in-kubernetes-f362369dff22

## Test results
Under load, the deployments get scaled up to 3 replicas each
```shell
NAME                                           CPU(cores)   MEMORY(bytes)
loadtest-nginx-phpfpm-nginx-8677d86c6d-6srnm   192m         9Mi
loadtest-nginx-phpfpm-nginx-8677d86c6d-b5gdr   195m         10Mi
loadtest-nginx-phpfpm-nginx-8677d86c6d-kd7gg   216m         6Mi
loadtest-nginx-phpfpm-phpfpm-b7c569b8c-7hl56   1265m        20Mi
loadtest-nginx-phpfpm-phpfpm-b7c569b8c-lw9tj   921m         11Mi
loadtest-nginx-phpfpm-phpfpm-b7c569b8c-tsnvr   792m         20Mi
```
Once the test is over, after about 5 minutes, the deployments get scaled down again
```shell
NAME                                           CPU(cores)   MEMORY(bytes)
loadtest-nginx-phpfpm-nginx-8677d86c6d-b5gdr   1m           10Mi
loadtest-nginx-phpfpm-phpfpm-b7c569b8c-lw9tj   1m           11Mi
```




## Missing features - help appreciated
* [ ] provide `nginx.conf` through `values.yaml` -> make it configurable
* [ ] test scenarios and/or examples
  * [x] test autoscaling
  * [ ] test persistence

## Contribute
* Create issues: Be specific. What do you expect? How do you suggest we get there?
* Create pull requests: Don't ask, just create a PR. Small improvements at a time please.
* See [Contributing](../../CONTRIBUTING.md) 

## Credits
* Icon from [Freepik](https://www.freepik.com) found on [FlatIcon](https://www.flaticon.com/)