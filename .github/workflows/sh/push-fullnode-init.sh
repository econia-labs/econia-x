#!/bin/sh

docker tag "$IMAGE_ID" \

echo "$IMAGE_ID"
TAG="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO"
echo $"TAG"

docker images