# DrupalCon Singapore 2024 Demo on Spinning Drupal 10 using terraform on AWS

## Build your docker image and push it to your AWS ECR where your container is running

    docker build --platform=linux/amd64 -t drupal-php -f Dockerfile-php .
    aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 64502xxxxxxxxxx.dkr.ecr.ap-southheast-1.amazonaws.com
    docker tag drupal-php:latest XXXXXXXXX91.dkr.ecr.ap-southeast-1.amazonaws.com/drupal-fargate:php-latest
    docker push XXXXXXXXXX91.dkr.ecr.ap-southeast-1.amazonaws.com/drupal-fargate:php-latest

* On mac
* You need to have a running docker and aws cli
* Login to your AWS ECR
