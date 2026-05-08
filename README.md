# Multi-Node Containerized Deployment with Terraform and AWS ECS

This project demonstrates a complete DevOps workflow for deploying a full-stack application (Flask Backend and Express Frontend) on AWS using Infrastructure as Code (Terraform) and Container Orchestration (ECS Fargate).

## 🚀 Project Overview

The deployment is structured into three progressive phases:
1.  **Phase 1:** Single-instance deployment on RHEL using Terraform.
2.  **Phase 2:** Multi-node EC2 deployment with dedicated VPC networking.
3.  **Phase 3:** High-availability containerized architecture using ECR, ECS Fargate, and an Application Load Balancer (ALB).

## 🏗️ Architecture

The final architecture (Phase 3) includes:
- **VPC Networking:** Custom VPC with public subnets across two Availability Zones (eu-north-1a & eu-north-1b).
- **Security:** Security Groups controlling traffic for HTTP (80), Flask (5000), and Express (3000).
- **Container Registry (ECR):** Private repositories for storing Docker images.
- **Orchestration (ECS):** Fargate cluster running independent services for frontend and backend.
- **Load Balancing (ALB):** Path-based routing to direct traffic:
    - http://app-alb-1305328457.eu-north-1.elb.amazonaws.com/flask
    - http://app-alb-1305328457.eu-north-1.elb.amazonaws.com/express

## 🛠️ Tech Stack
- **Infrastructure:** Terraform
- **Cloud Provider:** AWS (ECS, ECR, Fargate, ALB, VPC)
- **Containers:** Docker
- **Backend:** Python (Flask)
- **Frontend:** Node.js (Express)
- **OS Environment:** Red Hat Enterprise Linux (RHEL)

## 📖 Deployment Process

### 1. Infrastructure Provisioning
Initialize and apply the Terraform configuration to set up the networking, IAM roles, ECR repositories, and ECS cluster.
```bash
terraform init
terraform apply -auto-approve
```

### 2. Containerization & Registry Push
Authenticate Docker with AWS ECR, build the images using the provided Dockerfiles, and push them to the cloud.
```bash
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 905663669055.dkr.ecr.eu-north-1.amazonaws.com

# Build and Push Flask
docker build -t flask-backend ./backend
docker tag flask-backend:latest [905663669055.dkr.ecr.eu-north-1.amazonaws.com/flask-backend:latest](https://905663669055.dkr.ecr.eu-north-1.amazonaws.com/flask-backend:latest)
docker push [905663669055.dkr.ecr.eu-north-1.amazonaws.com/flask-backend:latest](https://905663669055.dkr.ecr.eu-north-1.amazonaws.com/flask-backend:latest)

# Build and Push Express
docker build -t express-frontend ./frontend
docker tag express-frontend:latest [905663669055.dkr.ecr.eu-north-1.amazonaws.com/express-frontend:latest](https://905663669055.dkr.ecr.eu-north-1.amazonaws.com/express-frontend:latest)
docker push [905663669055.dkr.ecr.eu-north-1.amazonaws.com/express-frontend:latest](https://905663669055.dkr.ecr.eu-north-1.amazonaws.com/express-frontend:latest)
```

### 3. Service Deployment
Trigger a manual redeployment to ensure ECS pulls the latest images and passes health checks.
```bash
aws ecs update-service --cluster app-cluster --service flask-service --force-new-deployment
aws ecs update-service --cluster app-cluster --service express-service --force-new-deployment
```