#!/bin/bash

set -e

# See more pre-setup scripts in ../.travis.yml

if [[ ! -f run.sh ]]
then
    echo "wrong dir to run tests from."
    exit 1
fi

cf login -a "$CF_ENDPOINT" -u "$CF_USER" -p "$CF_PASSWORD" -o "$CF_ORG" -s "$CF_SPACE" > /dev/null

echo "begin clean up of environment"
cf apps 2>&1 | grep ops- | awk '{print $1}' | xargs -n 1 -P 5 --no-run-if-empty cf delete -r -f | grep -v 'OK' || true
cf s 2>&1 | grep ops- | awk '{print $1}' | xargs -n 1 -P 5 --no-run-if-empty cf ds -f $service | grep -v 'OK' || true
echo "completed environment clean up"


echo 'starting test run, tests will run in parallel and output shown at the end'
nosetests -vv --processes=10 --process-timeout=600 --with-timer usecase/
