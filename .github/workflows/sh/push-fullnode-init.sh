#!/bin/sh
for tag in $TAGS; do
	TAG="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$tag"
	docker tag "$IMAGE_ID" "$TAG"
	docker push "$TAG"
done
