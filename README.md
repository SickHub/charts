[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/sickhub)](https://artifacthub.io/packages/search?org=sickhub)
[![Workflow Status](https://img.shields.io/github/actions/workflow/status/sickhub/charts/release.yaml)](https://github.com/SickHub/charts/actions)
[![license](https://img.shields.io/github/license/sickhub/charts.svg)](https://github.com/sickhub/charts/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/sickhub/charts.svg)](https://github.com/sickhub/charts)
[![Downloads](https://img.shields.io/github/downloads/SickHub/charts/total)](https://github.com/sickhub/charts/releases)
[![Contributors](https://img.shields.io/github/contributors/sickhub/charts.svg)](https://github.com/sickhub/charts/graphs/contributors)
[![Paypal](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=FTXDN7LCDWUEA&source=url)
[![GitHub Sponsor](https://img.shields.io/badge/github-sponsor-blue?logo=github)](https://github.com/sponsors/DrPsychick)

[![GitHub issues](https://img.shields.io/github/issues/sickhub/charts.svg)](https://github.com/sickhub/charts/issues)
[![GitHub closed issues](https://img.shields.io/github/issues-closed/sickhub/charts.svg)](https://github.com/sickhub/charts/issues?q=is%3Aissue+is%3Aclosed)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/sickhub/charts.svg)](https://github.com/sickhub/charts/pulls)
[![GitHub closed pull requests](https://img.shields.io/github/issues-pr-closed/sickhub/charts.svg)](https://github.com/sickhub/charts/pulls?q=is%3Apr+is%3Aclosed)

## Generic charts, like `cronjobs`, `nginx-phpfpm`, `mtr-exporter`
* requires helm v3

```shell script
helm repo add sickhub https://sickhub.github.io/charts
helm search repo sickhub
```

On Artifact Hub: https://artifacthub.io/packages/search?org=sickhub

## Contribute
* Create issues, create PRs, ... let's make this better together.
* See [Contributing](CONTRIBUTING.md)

### Publish new chart version
Create a PR that includes a version change in `Chart.yaml` of the Helm Chart. The action `chart-releaser` will detect
it, package it and create a new release in GitHub as well as update the `gh-pages` repository `index.yaml`.
