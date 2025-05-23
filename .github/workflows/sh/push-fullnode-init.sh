#!/bin/sh

docker tag "$IMAGE_ID" \
    "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO"
docker images