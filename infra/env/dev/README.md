DEV ECR Repository:
<your-account-id>.dkr.ecr.eu-central-1.amazonaws.com/dev-cors-proxy

aws sts get-caller-identity

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.eu-central-1.amazonaws.com

docker tag cors-proxy:latest <your-account-id>.dkr.ecr.eu-central-1.amazonaws.com/dev-cors-proxy:latest

docker push <your-account-id>.dkr.ecr.eu-central-1.amazonaws.com/dev-cors-proxy:latest

Prüfung:
aws ecr list-images --region eu-central-1 --repository-name dev-cors-proxy