#!/bin/sh

[ "$1" = "UPDATE" ] && UPDATE="true"

set -e

function bumpChartVersion() {
  v=$(grep '^version:' ./sickhub/$1/Chart.yaml | awk -F: '{print $2}' | tr -d ' ')
  patch=${v/*.*./}
  nv=${v/%$patch/}$((patch+1))
  sed -i "" -e "s/^version: .*/version: $nv/" ./sickhub/$1/Chart.yaml
}

# checkout github-pages
echo "--> Checkout gh-pages and rebase master"
git checkout gh-pages
git pull
git rebase master
git push

echo "--> Helm package and re-index"
for c in cronjobs nginx-phpfpm mtr-exporter; do
  [ -z "$(git status -s ./sickhub/$c/Chart.yaml)" -a -z "$UPDATE" ] && bumpChartVersion $c
  (cd sickhub; helm dependency update $c; helm package $c)
  mv ./sickhub/$c-*.tgz ./docs/
done

helm repo index ./docs --url https://sickhub.github.io/charts/

echo "--> Commit and push changes to gh-pages"
git add .
git commit -m "publish charts" -av
git push

# switch back to master and merge
echo "--> Checkout master and merge gh-pages"
git checkout master
git pull
git merge gh-pages
git push
