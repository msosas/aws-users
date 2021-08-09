#!/bin/bash

USER=$1

if [ -z $USER ]; then
  echo -e "ERROR: You didn't specify the user:\n >> ./credentials.sh john"
  exit 1
else
    mkdir -p ./credentials
    touch ./credentials/$USER.output
    echo "" > ./credentials/$USER.output

    AWS_PASSWORD=$(terraform output -json users_password | jq -r '.["'$USER'"]["encrypted_password"]' | base64 --decode | keybase pgp decrypt)
    AWS_ACCESS_KEY=$(terraform output -json users_access_keys | jq -r '.["'$USER'"]["id"]')
    AWS_SECRET_KEY=$(terraform output -json users_access_keys | jq -r '.["'$USER'"]["encrypted_secret"]' | base64 --decode | keybase pgp decrypt)

    echo -e "Login URL: https://577602312581.signin.aws.amazon.com/console \nUser: $USER\nPassword: $AWS_PASSWORD\nAWS_ACCESS_KEY: $AWS_ACCESS_KEY\nAWS_SECRET_KEY: $AWS_SECRET_KEY" > ./credentials/$USER.output
fi