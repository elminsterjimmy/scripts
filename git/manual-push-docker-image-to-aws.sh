#!/bin/bash


PROJECT_NAME=$1


# To Run this you need AWS Credentials from Woody which allows Login and write to ECR.
# Also please make sure you run mvn build beforehand as this needs the target/XXX.jar available
# login to AWS ECR - this runs out after day I think
aws ecr get-login-password --region cn-north-1 | docker login --username AWS --password-stdin 014301917773.dkr.ecr.cn-north-1.amazonaws.com.cn
# Generate commit hash
commitHash=$(git rev-parse HEAD | cut -c 1-7)


echo "project name $PROJECT_NAME, commit hash $commitHash"

#Build Image
IMAGE_TAG=dev-$commitHash docker-compose build $PROJECT_NAME

#Tag Image locally
docker tag edtech-kt/$PROJECT_NAME:dev-$commitHash 014301917773.dkr.ecr.cn-north-1.amazonaws.com.cn/edtech-kt/$PROJECT_NAME:dev-$commitHash
#Push tagged Image
docker push 014301917773.dkr.ecr.cn-north-1.amazonaws.com.cn/edtech-kt/$PROJECT_NAME:dev-$commitHash

#Remove local Tagged index
docker rmi 014301917773.dkr.ecr.cn-north-1.amazonaws.com.cn/edtech-kt/$PROJECT_NAME:dev-$commitHash

# TAG LOCAL AS latest-dev
docker tag edtech-kt/$PROJECT_NAME:dev-$commitHash 014301917773.dkr.ecr.cn-north-1.amazonaws.com.cn/edtech-kt/$PROJECT_NAME:latest-dev

# PUSH latest-dev
docker push 014301917773.dkr.ecr.cn-north-1.amazonaws.com.cn/edtech-kt/$PROJECT_NAME:latest-dev
# Cleanup images
docker rmi 014301917773.dkr.ecr.cn-north-1.amazonaws.com.cn/edtech-kt/$PROJECT_NAME:latest-dev
docker rmi edtech-kt/$PROJECT_NAME:dev-$commitHash

# Cleanup Docker
docker system prune -f --volumes


