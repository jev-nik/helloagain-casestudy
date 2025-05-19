# CORS-Proxy Deployment on AWS EKS with ALB

This guide provides instructions to deploy a CORS-Proxy application on an AWS EKS cluster, exposed publicly via an Application Load Balancer (ALB) managed by the AWS Load Balancer Controller. The setup uses Terraform for infrastructure and Kubernetes manifests for the application, with a custom Docker image hosted in AWS ECR.

## Prerequisites

- **AWS Account**: With permissions to create EKS clusters, ALB, and ECR repositories.
- **AWS CLI**: Configured with credentials (`aws configure`).
- **Docker**: Installed locally for building and pushing images.
- **kubectl**: Installed and configured for EKS access.
- **Terraform**: Installed for infrastructure setup.

## Step 1: Build and Push Docker Image and apply infrastructure

Inside infra/dev/env:
 terraform apply

1. **Clone or Create Project Directory**:
   ```bash
   mkdir cors-proxy-app
   cd cors-proxy-app
   ```

2. **Create Application Files**:
   - Use the provided `index.js`, `Dockerfile`, and `package.json` (see repository or artifacts).
   - Place them in `cors-proxy-app/`.

3. **Authenticate with AWS ECR**:
   Replace `AWS_ACCOUNT` with your AWS account ID (e.g., `${AWS_ACCOUNT}`).
   ```bash
   aws sts get-caller-identity
   aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin AWS_ACCOUNT.dkr.ecr.${REGION}.amazonaws.com
   ```

4. **Build and Push Docker Image**:
   ```bash
   docker buildx build --platform linux/amd64 -t cors-proxy:latest --load .
   docker tag cors-proxy:latest AWS_ACCOUNT.dkr.ecr.${REGION}.amazonaws.com/dev-cors-proxy:v2
   docker push AWS_ACCOUNT.dkr.ecr.${REGION}.amazonaws.com/dev-cors-proxy:v2
   ```

5. **Verify Image in ECR**:
   ```bash
   aws ecr list-images --region ${REGION} --repository-name dev-cors-proxy
   ```

**ECR Repository**: `<your-account-id>.dkr.ecr.${REGION}.amazonaws.com/dev-cors-proxy`

## Step 2: Set Up AWS Load Balancer Controller Image

1. **Pull and Tag Controller Image**:
   ```bash
   docker pull --platform linux/amd64 public.ecr.aws/eks/aws-load-balancer-controller:v2.7.2
   docker tag public.ecr.aws/eks/aws-load-balancer-controller:v2.7.2 AWS_ACCOUNT.dkr.ecr.${REGION}.amazonaws.com/dev-cors-proxy:aws-load-balancer-controller-v2.7.2
   ```

2. **Push to ECR**:
   ```bash
   docker push AWS_ACCOUNT.dkr.ecr.${REGION}.amazonaws.com/dev-cors-proxy:aws-load-balancer-controller-v2.7.2
   ```

## Step 3: Configure EKS Cluster and OIDC Provider

1. **Update kubectl Config**:
   ```bash
   aws eks update-kubeconfig --region ${REGION} --name dev-eks-cluster
   kubectl get nodes
   ```

2. **Set Up OIDC Provider**:
   - Fetch the OIDC certificate:
     ```bash
     echo | openssl s_client -servername oidc.eks.${REGION}.amazonaws.com -showcerts -connect oidc.eks.${REGION}.amazonaws.com:443 2>/dev/null | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' > eks-oidc-cert.pem
     ```
   - Save the root CA certificate separately as `root-ca.pem`.
   - Get the SHA1 fingerprint:
     ```bash
     openssl x509 -in root-ca.pem -fingerprint -sha1 -noout | awk -F= '{print tolower($2)}' | tr -d ':'
     ```
   - Insert the fingerprint into your Terraform OIDC provider resource.

## Step 4: Deploy Kubernetes Resources

1. **Set Environment Variable**:
   ```bash
   export AWS_ACCOUNT_ID=<your-account-id>
   ```

2. **Install cert-manager**:
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.yaml
   ```

3. **Install AWS Load Balancer Controller CRDs**:
   ```bash
   kubectl apply -k "https://github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
   ```

4. **Deploy AWS Load Balancer Controller**:
   ```bash
   kubectl apply -f /application/manifest/v2_12_0_full.yaml
   ```
   - Verify:
     ```bash
     kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
     kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
     ```

5. **Install Metrics Server**:
   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```
   - Verify:
     ```bash
     kubectl get pods -n kube-system -l k8s-app=metrics-server
     ```

6. **Deploy CORS-Proxy Application**:
   ```bash
   envsubst < /application/deployment/cors-proxy-deployment.yaml | kubectl apply -f -
   ```
   - Verify pods:
     ```bash
     kubectl get pods -n default -l app=cors-proxy
     ```

7. **Deploy Ingress Class**:
   ```bash
   kubectl apply -f /application/deployment/ingress-class.yaml
   ```
   - Verify:
     ```bash
     kubectl get ingressclass alb
     ```

8. **Deploy TargetGroupBinding**:
   ```bash
   kubectl apply -f /application/deployment/cors-proxy-tgb.yaml
   ```

9. **Configure Security Group**:
   ```bash
   aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP} --protocol tcp --port 8080 --cidr 0.0.0.0/0 --region ${REGION}
   ```

10. **Deploy Ingress**:
    ```bash
    kubectl apply -f /application/deployment/cors-proxy-ingress.yaml
    kubectl describe ingress cors-proxy-ingress -n default
    ```

## Step 5: Create and Configure Target Group

1. **Create Target Group**:
   ```bash
   aws elbv2 create-target-group --name k8s-default-corsprox-20250519 --protocol HTTP --port 8080 --target-type ip --vpc-id ${VPC_ID} --region ${REGION}
   ```

2. **Update Health Check**:
   Configure the target group to use the `/health` endpoint:
   ```bash
   aws elbv2 modify-target-group --target-group-arn arn:aws:elasticloadbalancing:${REGION}:${AWS_ACCOUNT}:targetgroup/${TARGET_GROUP} --health-check-path=/health --matcher HttpCode=200 --health-check-timeout-seconds 10 --health-check-interval-seconds 30 --healthy-threshold-count 2 --unhealthy-threshold-count 2 --region ${REGION}
   ```

## Step 6: Test Deployment

1. **Verify Pod Health**:
   ```bash
   aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:${REGION}:${AWS_ACCOUNT}:targetgroup/${TARGET_GROUP} --region ${REGION}
   ```

2. **Test CORS-Proxy**:
   ```bash
   curl "http://<alb-dns>?url=https://example.com"
   ```