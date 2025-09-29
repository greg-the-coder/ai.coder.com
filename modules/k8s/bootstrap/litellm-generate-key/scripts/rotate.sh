#!/bin/bash

set -eo pipefail

curl -L -X POST "$LITELLM_URL/user/new" \
    -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
    -H 'Content-Type: application/json' \
    -d "{\"username\":\"$USERNAME\",\"user_id\":\"$USERNAME\",\"email\":\"$USER_EMAIL\",\"key_alias\":\"$KEY_NAME\",\"duration\":\"$KEY_DURATION\"}" || true ;

curl -L -X POST "$LITELLM_URL/key/delete" \
    -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
    -H 'Content-Type: application/json' \
    -d "{\"key_aliases\":[\"$KEY_NAME\"]}" || true ;

NEW_LITELLM_USER_KEY=$(curl -L -X POST $LITELLM_URL/key/generate \
    -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
    -H 'Content-Type: application/json' \
    -d "{\"key_alias\":\"$KEY_NAME\",\"duration\":\"$KEY_DURATION\",\"metadata\":{\"user_id\":\"$USERNAME\"}}" | jq -r '.key') ;

aws secretsmanager put-secret-value \
    --region $AWS_SECRET_REGION \
    --secret-id $AWS_SECRETS_MANAGER_ID \
    --secret-string "{\"LITELLM_MASTER_KEY\":\"$NEW_LITELLM_USER_KEY\"}" || \
aws secretsmanager create-secret \
    --region $AWS_SECRET_REGION \
    --name $AWS_SECRETS_MANAGER_ID \
    --secret-string "{\"LITELLM_MASTER_KEY\":\"$NEW_LITELLM_USER_KEY\"}"