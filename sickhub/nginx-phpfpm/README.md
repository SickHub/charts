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

## Load testing
Install the Chart with `loadtest-values.yaml` which includes a few simple scripts (endpoints), one of which causes
the PHP process to consume all available CPU for a few seconds.
```shell
helm upgrade --install load-test sickhub/nginx-phpfpm --values sickhub/nginx-phpfpm/ci/loadtest-values.yaml
```

Make sure to increase your limits, if you run everything on your local machine:
### MacOS
```shell
sudo sysctl -w kern.maxfiles=1048600
sudo sysctl -w kern.maxfilesperproc=1048576
ulimit -S -n 1048576
sudo sysctl -w kern.ipc.somaxconn=16384
sudo sysctl -w net.inet.tcp.msl=1000 # reduce TIME_WAIT to 2s
sudo sysctl -w net.inet.ip.portrange.first=40000 # increase number of outgoing ports
sudo sysctl -w net.inet.ip.portrange.hifirst=40000
```
### Linux
```shell
sudo sysctl -w fs.file-max=1048600
sudo sysctl -w net.core.somaxconn=16384
sudo sysctl -w net.ipv4.tcp_fin_timeout=1

```

### Run tests with `siege`
- `-d 1` delay up to 1s before each request (i.e. ~1 req/sec per thread)
- `-t 20S` run for 20 seconds (alternative `-r 10` 10 rounds per thread)
- `-c 5` 5 parallel requests
```shell
siege -d 1 -r 10 -c 50 http://localhost/health.php # 50 threads, each doing 20 requests, one per second
siege -d 1 -t 20S -c 5 http://localhost/ok.html # static HTML page from Nginx
siege -d 1 -t 20S -c 20 http://localhost/health.php # phpinfo from PHP container
siege -d 1 -r 2 -c 5 http://localhost/load.php # 100% load for X seconds, then return phpinfo
```

Run test suite
```shell
echo "" > local-siege.txt
for i in $(seq 1 20); do echo "http://localhost/health.php" >> local-siege.txt; done
for i in $(seq 1 10); do echo "http://localhost/livez.html" >> local-siege.txt; done
echo "http://localhost/load.php" >> local-siege.txt
# take random URLs from above file, 80 threads, 30 requests per thread
siege -d 1 -r 30 -c 80 -i -f local-siege.txt
```

You will notice, that with the right `shutdownDelay` and deployment `strategy`, you can get your installation to do
an update without dropping a single request (100% availability while doing a rollingUpdate).

While running the test suite, simply apply a small change via helm (memory limits for example) and watch the pods being
created and gracefully terminated without missing a request.

See also: https://medium.com/inside-personio/graceful-shutdown-of-fpm-and-nginx-in-kubernetes-f362369dff22

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