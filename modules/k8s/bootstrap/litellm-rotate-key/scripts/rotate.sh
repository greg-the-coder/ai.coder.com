#!/bin/bash

set -eo pipefail

LITELLM_MASTER_KEY=$(aws secretsmanager get-secret-value \
    --region $AWS_SECRET_REGION \
    --secret-id $AWS_SECRETS_MANAGER_ID | jq -r '.SecretString' | jq -r '.LITELLM_MASTER_KEY')

kubectl create secret generic litellm -n $K8S_NAMESPACE -o yaml --dry-run=client \
    --from-literal=token=$LITELLM_MASTER_KEY | kubectl apply -f -