#!/usr/env/bin bash

set -e

AWS_REGION=${AWS_REGION:-us-east-2}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-}
IMAGE_REPO=${IMAGE_REPO:-ghcr.io/coder}
IMAGE_NAME=${IMAGE_NAME:-coder-preview}
IMAGE_TAG=${IMAGE_TAG:-latest}

IMAGE="${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"

if ! aws ecr describe-repositories --region $AWS_REGION --repository-names $IMAGE_NAME; then
    return 1;
fi

aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker pull $IMAGE && \
    docker tag $IMAGE $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG && \
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG