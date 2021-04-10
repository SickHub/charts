#!/bin/sh

[ "$1" = "UPDATE" ] && UPDATE="true"

set -e

function bumpChartVersion() {
  v=$(grep '^version:' ./drpsychick/$1/Chart.yaml | awk -F: '{print $2}' | tr -d ' ')
  patch=${v/*.*./}
  nv=${v/%$patch/}$((patch+1))
  sed -i "" -e "s/version: .*/version: $nv/" ./drpsychick/$1/Chart.yaml
}

# checkout github-pages
git checkout gh-pages
git pull
git rebase master
git push

for c in cronjobs; do
  [ -z "$(git status -s ./drpsychick/$c/Chart.yaml)" -a -z "$UPDATE" ] && bumpChartVersion $c
  (cd drpsychick; helm package $c)
  mv ./drpsychick/$c-*.tgz ./docs/
done

helm repo index ./docs --url https://drpsychick.github.io/charts/

git add .
git commit -m "publish charts" -av
git push

# switch back to master and merge
git checkout master
git pull
git merge gh-pages
git push