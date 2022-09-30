#!/bin/bash

debug=0
if [[ $# -eq 0 ]]; then
  echo 'usage: refresh/create your AssumeRole profile credentials [parameters]'
  echo 'paramters:'
  echo '-m --mfa-arn: Your AXxxxx MFA arn'
  echo '-a --account-id: the account id of target account'
  echo "-p --profile: the target account's name"
  echo '-r --role: The assume role in target account'
  echo '-t --token: the MFA token'
  echo '-j --jumper: the profile name of jumper account'
  echo '-d --duration: the duration of the token'
  echo
  echo "Example"
  echo './create-assume-role-creds.sh -m arn:aws:iam::3434343434:mfa/asdfasdfas -a 123123123123 -p mlv2-dev -r G-Admin -j anika -d 3600 -t 888777'
  exit 1
fi

while [[ "$#" > 0 ]]; do
  case $1 in
  -m | --mfa-arn)
    mfa="$2"
    shift
    ;;
  -a | --account-id)
    account_id="$2"
    shift
    ;;
  -p | --profile)
    profile="$2"
    shift
    ;;
  -r | --role)
    role="$2"
    shift
    ;;
  -t | --token)
    token="$2"
    shift
    ;;
  -j | --jumper)
    jumper="$2"
    shift
    ;;
  -d | --duration)
    duration="$2"
    shift
    ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

cred=$(aws --profile ${jumper} \
sts assume-role \
--role-arn arn:aws:iam::${account_id}:role/${role} \
--role-session-name assumeSessions${account_id}${role} \
--serial-number ${mfa} \
--token-code ${token} \
--duration-seconds ${duration})

access_key=$(echo $cred |jq -r '.Credentials.AccessKeyId')
secret_key=$(echo $cred |jq -r '.Credentials.SecretAccessKey')
session_token=$(echo $cred |jq -r '.Credentials.SessionToken')

aws configure set aws_access_key_id ${access_key} --profile ${profile}
aws configure set aws_secret_access_key ${secret_key} --profile ${profile}
aws configure set aws_session_token ${session_token} --profile ${profile}
