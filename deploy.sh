#!/usr/bin/env bash

set -eu

aws --version
jq --version

sourcedir=cloudwatch-logs-to-slack-python3
s3bucket=611000245893-us-east-1-serverless-application-repository
commandargjson=j.json

cd $sourcedir
aws cloudformation package \
  --template-file template.yaml \
  --output-template-file template.deploy \
  --s3-bucket $s3bucket
cd ..

cat create-application.json | \
  jq \
    --arg lb "$(cat LICENSE)" \
    --arg rb "$(cat README.md)" \
    --arg tb "$(cat cloudwatch-logs-to-slack-python3/template.deploy)" \
    '. + { LicenseBody: $lb, ReadmeBody: $rb, TemplateBody: $tb }' \
    > $commandargjson

aws serverlessrepo create-application --cli-input-json file://$commandargjson
