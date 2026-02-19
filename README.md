# 🚀 AWS ECS + RDS Infrastructure - Production-Grade 2-Tier Architecture

[![Terraform](https://img.shields.io/badge/Terraform-v1.8+-623CE4?style=flat&logo=terraform)](https://www.terraform.io/) [![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=flat&logo=amazon-aws)](https://aws.amazon.com/) [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE) [![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen.svg)](https://github.com/KUNAL-MAURYA1470/aws-ecs-rds)

> Enterprise-grade Infrastructure as Code (IaC) for deploying containerized applications on AWS ECS Fargate with PostgreSQL RDS. Built with Terraform for scalability, security, and high availability.

---

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Features](#-features)
- [Infrastructure Components](#-infrastructure-components)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Module Documentation](#-module-documentation)
- [Configuration](#-configuration)
- [Security Features](#-security-features)
- [Monitoring & Observability](#-monitoring--observability)
- [Database Access](#-database-access)
- [Cost Optimization](#-cost-optimization)
- [Troubleshooting](#-troubleshooting)
- [Cleanup](#-cleanup)
- [License](#-license)

---

## 🏗️ Architecture Overview

![Infrastructure Architecture](./architecture-2tier.png)

*Complete 2-tier architecture showcasing ECS Fargate, RDS PostgreSQL, and supporting AWS services*

### Architecture Highlights

- **Multi-AZ Deployment**: High availability across 2 availability zones
- **Serverless Containers**: ECS Fargate with auto-scaling (no EC2 management)
- **Managed Database**: PostgreSQL RDS with automated backups and encryption
- **Secure by Design**: Private subnets, WAF protection, Secrets Manager integration
- **Auto-Scaling**: Dynamic scaling based on CPU utilization (2-6 tasks)
- **Zero-Downtime Deployments**: Rolling updates with Application Load Balancer

---

## ✨ Features

### 🚀 Performance & Scalability
- **Auto-scaling ECS Services**: Scales from 2 to 6 tasks based on CPU demand (60% target)
- **Application Load Balancer**: Intelligent traffic distribution with health checks
- **NAT Gateway**: High availability for outbound internet traffic
- **ECR Integration**: Private container registry for fast image pulls
- **Multi-AZ RDS**: Automatic failover for database high availability

### 🔒 Security & Compliance
- **Network Isolation**: Private subnets for application and database tiers
- **Encryption Everywhere**: RDS encryption at rest, TLS in transit
- **Secrets Manager**: Automatic password rotation (30-day cycle) with Lambda
- **WAF Protection**: Rate limiting (2000 req/5min) and AWS managed rule sets
- **Least Privilege IAM**: Separate execution and task roles with minimal permissions
- **S3 Security**: Public access blocked, server-side encryption enabled

### 📊 Observability
- **CloudWatch Logs**: Centralized logging for all ECS tasks
- **30-Day Log Retention**: Configurable retention policies for compliance
- **Performance Insights**: RDS performance monitoring enabled
- **Auto Minor Version Upgrades**: Automatic security patches for RDS

### 💰 Cost Optimization
- **Right-Sized Resources**: db.t4g.medium for RDS, configurable CPU/memory for ECS
- **Resource Tagging**: Comprehensive tagging for cost allocation
- **Single NAT Gateway**: Cost-effective design for dev/staging environments
- **Deletion Protection**: RDS deletion protection enabled by default

---

## 🧩 Infrastructure Components

| Component | Service | Purpose |
|-----------|---------|---------|
| **Compute** | ECS Fargate | Serverless container orchestration |
| **Load Balancing** | Application Load Balancer | Traffic distribution and health checks |
| **Networking** | VPC, Subnets, NAT Gateway | Network isolation and internet access |
| **Database** | RDS PostgreSQL 16.3 | Primary relational database |
| **Container Registry** | ECR | Private Docker image repository |
| **Security** | WAF | Web application firewall protection |
| **Secrets** | Secrets Manager + Lambda | Credential management with auto-rotation |
| **Storage** | S3 | Application data storage |
| **Monitoring** | CloudWatch | Metrics, logs, and alarms |
| **IAM** | IAM Roles & Policies | Identity and access management |

---

## 📦 Prerequisites

### Required Tools
```bash
# Terraform
terraform >= 1.8.0

# AWS CLI
aws-cli >= 2.0

# Docker
docker >= 20.0
```

### AWS Account Setup
- AWS Account with administrative access
- AWS CLI configured with appropriate credentials
- Sufficient service quotas for ECS, RDS, and VPC resources

---

## 🚀 Quick Start

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/KUNAL-MAURYA1470/aws-ecs-rds.git
cd aws-ecs-rds
```

### 2️⃣ Configure Variables

Edit `terraform.tfvars` with your desired settings:

```hcl
aws_region   = "us-east-1"
project_name = "my-app"
environment  = "prod"

# Update with your ECR image URI
ecs_task_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"

# Network configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = {
  a = "10.0.1.0/24"
  b = "10.0.2.0/24"
}
private_subnet_cidrs = {
  a = "10.0.11.0/24"
  b = "10.0.12.0/24"
}

# ECS configuration
ecs_desired_count    = 2
ecs_container_cpu    = 512
ecs_container_memory = 1024
ecs_container_port   = 8080

# RDS configuration
db_instance_class    = "db.t4g.medium"
db_allocated_storage = 50
db_multi_az          = true
```

### 3️⃣ Initialize Terraform
```bash
terraform init
```

### 4️⃣ Review the Plan
```bash
terraform plan
```

### 5️⃣ Deploy Infrastructure
```bash
terraform apply
```

### 6️⃣ Build and Push Docker Image to ECR

```bash
# Get ECR repository URL
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $ECR_URL

# Build and push your image
docker build -t my-app .
docker tag my-app:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

### 7️⃣ Update ECS Service

After pushing your image, update the ECS service:

```bash
aws ecs update-service \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --service $(terraform output -raw ecs_service_name) \
  --force-new-deployment \
  --region us-east-1
```

### 8️⃣ Access Your Application

```bash
# Get ALB DNS name
terraform output alb_dns_name

# Access your application
curl http://$(terraform output -raw alb_dns_name)
```

---

## 📚 Module Documentation

### VPC Module (`modules/vpc`)

**Purpose**: Creates the network foundation with public and private subnets across multiple AZs.

**Resources Created**:
- 1 VPC with DNS support enabled
- 2 Public subnets (for ALB and NAT Gateway)
- 2 Private subnets (for ECS tasks and RDS)
- 1 NAT Gateway with Elastic IP
- Internet Gateway
- Route tables and associations
- Default security group for private resources

**Key Features**:
- Multi-AZ for high availability
- Separate subnet tiers for security
- Automatic AZ selection if not specified

---

### ECS Module (`modules/ecs`)

**Purpose**: Manages containerized workloads using ECS Fargate.

**Resources Created**:
- ECS Cluster with execute command configuration
- ECS Task Definition (Fargate compatible)
- ECS Service with load balancer integration
- Security Group for ECS tasks
- Auto-scaling target and policy

**Scaling Configuration**:
- Min Tasks: 2 (configurable)
- Max Tasks: 6 (configurable)
- Target CPU: 60%
- Scale-in cooldown: 120 seconds
- Scale-out cooldown: 60 seconds

**Environment Variables Injected**:
- `DB_HOST`: RDS endpoint
- `DB_PORT`: Database port (5432)
- `DB_NAME`: Database name
- `DB_USER`: Database username
- `AWS_REGION`: Current AWS region
- `DB_SECRET`: Full secret JSON from Secrets Manager

---

### RDS Module (`modules/rds`)

**Purpose**: Provides managed PostgreSQL database with automatic credential rotation.

**Resources Created**:
- RDS PostgreSQL 16.3 instance
- DB subnet group
- Security group for database access
- Secrets Manager secret with rotation
- Lambda function for password rotation
- IAM roles and policies for Lambda

**Features**:
- Encryption at rest enabled
- Performance Insights enabled
- Automated backups (7-day retention)
- Automatic minor version upgrades
- Deletion protection enabled
- Multi-AZ deployment support
- 30-day automatic password rotation

---

### ALB Module (`modules/alb`)

**Purpose**: Distributes incoming traffic across ECS tasks.

**Resources Created**:
- Application Load Balancer (internet-facing)
- Target Group (IP target type for Fargate)
- HTTP Listener (port 80)
- Security Group for ALB

**Health Check Configuration**:
- Path: `/health`
- Interval: 30 seconds
- Timeout: 5 seconds
- Healthy threshold: 3
- Unhealthy threshold: 3
- Success codes: 200-399

---

### IAM Module (`modules/iam`)

**Purpose**: Manages IAM roles and policies for ECS tasks and application access.

**Resources Created**:
- ECS Task Execution Role (for pulling images, writing logs)
- ECS Task Role (for application permissions)
- S3 bucket for application data
- CloudWatch Log Group
- IAM policies for Secrets Manager and S3 access

**Permissions Granted**:
- **Execution Role**: ECR pull, CloudWatch logs, Secrets Manager read
- **Task Role**: S3 read/write, Secrets Manager read

---

### WAF Module (`modules/waf`)

**Purpose**: Protects the application from common web exploits.

**Resources Created**:
- WAFv2 Web ACL
- Web ACL association with ALB

**Rules Configured**:
1. **AWS Managed Rules Common Rule Set**: Protection against OWASP Top 10
2. **Rate Limiting**: 2000 requests per 5 minutes per IP

---

### ECR Module (`modules/ecr`)

**Purpose**: Provides private container registry for Docker images.

**Resources Created**:
- ECR repository with image scanning enabled
- Lifecycle policy (keeps last 10 images)

---

## ⚙️ Configuration

### Key Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region | - | Yes |
| `project_name` | Project name prefix | `ecs-rds-app` | No |
| `environment` | Environment name | `prod` | No |
| `ecs_task_image` | Docker image URI | - | Yes |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` | No |
| `ecs_desired_count` | Initial task count | `2` | No |
| `ecs_container_cpu` | CPU units (256, 512, 1024, etc.) | `512` | No |
| `ecs_container_memory` | Memory in MiB | `1024` | No |
| `ecs_container_port` | Container port | `8080` | No |
| `db_instance_class` | RDS instance type | `db.t4g.medium` | No |
| `db_allocated_storage` | RDS storage in GB | `50` | No |
| `db_multi_az` | Enable Multi-AZ | `true` | No |
| `waf_rate_limit` | WAF rate limit | `2000` | No |

See `terraform.tfvars.example` for all available options.

---

## 🔐 Security Features

### Network Security
- ✅ Private subnets for ECS tasks and RDS (no direct internet access)
- ✅ Security groups with principle of least privilege
- ✅ NAT Gateway for outbound internet access from private subnets
- ✅ ALB in public subnets with restricted ingress (HTTP/HTTPS only)

### Data Security
- ✅ RDS encryption at rest enabled
- ✅ S3 server-side encryption (AES256)
- ✅ Secrets stored in AWS Secrets Manager
- ✅ TLS in transit for all communications

### Access Control
- ✅ IAM roles with minimal permissions
- ✅ Separate execution and task roles for ECS
- ✅ Secrets Manager integration (no hardcoded credentials)
- ✅ S3 public access blocked

### Application Security
- ✅ WAF with AWS managed rules (OWASP Top 10 protection)
- ✅ Rate limiting to prevent DDoS attacks
- ✅ Automatic security patches for RDS

---

## 📊 Monitoring & Observability

### View ECS Logs
```bash
# Tail logs in real-time
aws logs tail /ecs/$(terraform output -raw project_name)-$(terraform output -raw environment) \
  --follow \
  --region us-east-1

# View specific time range
aws logs tail /ecs/my-app-prod \
  --since 1h \
  --region us-east-1
```

### Check ECS Service Health
```bash
aws ecs describe-services \
  --cluster $(terraform output -raw ecs_cluster_name) \
  --services $(terraform output -raw ecs_service_name) \
  --region us-east-1 \
  --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'
```

### Monitor RDS Performance
```bash
# Check RDS instance status
aws rds describe-db-instances \
  --db-instance-identifier $(terraform output -raw rds_endpoint | cut -d: -f1) \
  --region us-east-1 \
  --query 'DBInstances[0].{Status:DBInstanceStatus,MultiAZ:MultiAZ,Engine:Engine}'
```

### Key Metrics to Monitor
- **ECS Service CPU/Memory**: Target < 60%
- **ALB Target Health**: All targets should be healthy
- **RDS CPU Utilization**: Target < 80%
- **RDS Storage**: Monitor free storage space

---

## 🗄️ Database Access

### Get Database Credentials
```bash
# Retrieve full secret
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw rds_secret_arn) \
  --region us-east-1 \
  --query SecretString --output text | jq .

# Get just the password
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw rds_secret_arn) \
  --region us-east-1 \
  --query SecretString --output text | jq -r .password
```

### Connect to RDS (via Bastion or VPN)

**Note**: RDS is in a private subnet and not publicly accessible. You'll need a bastion host or VPN connection.

```bash
# Get connection details
DB_HOST=$(terraform output -raw rds_endpoint | cut -d: -f1)
DB_USER=$(aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw rds_secret_arn) \
  --query SecretString --output text | jq -r .username)
DB_PASS=$(aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw rds_secret_arn) \
  --query SecretString --output text | jq -r .password)

# Connect using psql
psql -h $DB_HOST -U $DB_USER -d appdb
```

### Environment Variables in ECS Tasks

The RDS credentials are automatically injected into ECS tasks:
- `DB_HOST`: RDS endpoint
- `DB_PORT`: 5432
- `DB_NAME`: Database name
- `DB_USER`: Database username
- `DB_SECRET`: Full secret JSON (parse to get password)

---

## 💰 Cost Optimization

### Estimated Monthly Cost (us-east-1)

| Service | Configuration | Estimated Cost |
|---------|---------------|----------------|
| ECS Fargate | 2 tasks (0.5 vCPU, 1 GB) | ~$30 |
| Application Load Balancer | 1 ALB + data processing | ~$20 |
| NAT Gateway | 1 NAT Gateway + data transfer | ~$32 |
| RDS PostgreSQL | db.t4g.medium (50 GB storage) | ~$60 |
| ECR | Storage + data transfer | ~$5 |
| Secrets Manager | 1 secret with rotation | ~$1 |
| CloudWatch Logs | 30-day retention | ~$5 |
| **Total** | | **~$153/month** |

*Costs vary based on data transfer, storage, and actual usage*

### Cost-Saving Tips

1. **Use Fargate Spot** for non-critical workloads (70% savings)
   - Modify task definition to use `FARGATE_SPOT` capacity provider
   
2. **Reserved Instances** for RDS if usage is predictable
   - 1-year RI: ~40% savings
   - 3-year RI: ~60% savings

3. **Right-size resources** based on actual usage
   - Monitor CloudWatch metrics
   - Adjust CPU/memory after analyzing usage patterns

4. **Optimize NAT Gateway costs**
   - Use VPC endpoints for AWS services (S3, ECR, Secrets Manager)
   - Reduces data transfer through NAT Gateway

5. **CloudWatch Log retention tuning**
   - 7 days for dev/staging environments
   - 30 days for production (current setting)

6. **Single NAT Gateway** (current design)
   - Cost-effective for dev/staging
   - For production, consider Multi-AZ NAT for higher availability

---

## 🐛 Troubleshooting

### Issue 1: ECS Tasks Failing to Start

**Symptom**: Tasks stuck in "PENDING" state or immediately stopping

**Solution**:
```bash
# Check CloudWatch logs
aws logs tail /ecs/my-app-prod --follow

# Common causes:
# 1. Image pull errors - verify ECR permissions
# 2. Insufficient memory/CPU - check task definition
# 3. Health check failures - verify /health endpoint
# 4. Security group blocking traffic - check SG rules
```

### Issue 2: ALB Health Checks Failing

**Symptom**: Targets marked as unhealthy in target group

**Solution**:
```bash
# Verify health check endpoint responds
curl http://<task-ip>:8080/health

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw ecs_security_group_id)

# Update health check path if needed
# Edit modules/alb/main.tf and change path = "/health"
```

### Issue 3: Cannot Connect to RDS

**Symptom**: Connection timeout or refused

**Solution**:
```bash
# Verify security group allows traffic from ECS
# Check main.tf - aws_security_group_rule.rds_ingress_from_ecs

# Verify RDS is running
aws rds describe-db-instances \
  --db-instance-identifier my-app-prod-postgres

# Check if RDS is in private subnet (should be)
# RDS should NOT be publicly accessible
```

### Issue 4: High RDS CPU Usage

**Symptom**: Database performance degradation

**Solution**:
```bash
# Check Performance Insights
aws rds describe-db-instances \
  --db-instance-identifier my-app-prod-postgres \
  --query 'DBInstances[0].PerformanceInsightsEnabled'

# Scale up instance class
# Update terraform.tfvars:
# db_instance_class = "db.t4g.large"
# Then: terraform apply
```

### Issue 5: Terraform Apply Fails

**Common Errors**:

1. **Secret already exists**:
   ```bash
   # Delete existing secret
   aws secretsmanager delete-secret \
     --secret-id my-app-prod/rds/postgresql \
     --force-delete-without-recovery
   ```

2. **NAT Gateway allocation limit**:
   ```bash
   # Request limit increase via AWS Support
   # Or release unused Elastic IPs
   ```

3. **RDS deletion protection**:
   ```bash
   # Disable deletion protection
   aws rds modify-db-instance \
     --db-instance-identifier my-app-prod-postgres \
     --no-deletion-protection \
     --apply-immediately
   ```

---

## 🧹 Cleanup

### Destroy Infrastructure

```bash
# Disable RDS deletion protection first
aws rds modify-db-instance \
  --db-instance-identifier $(terraform output -raw rds_endpoint | cut -d: -f1) \
  --no-deletion-protection \
  --apply-immediately \
  --region us-east-1

# Wait for modification to complete (2-3 minutes)
aws rds wait db-instance-available \
  --db-instance-identifier $(terraform output -raw rds_endpoint | cut -d: -f1)

# Destroy all resources
terraform destroy
```

### Manual Cleanup (if needed)

```bash
# Delete ECR images
aws ecr batch-delete-image \
  --repository-name $(terraform output -raw ecr_repository_url | cut -d/ -f2) \
  --image-ids imageTag=latest

# Force delete Secrets Manager secret
aws secretsmanager delete-secret \
  --secret-id $(terraform output -raw rds_secret_arn) \
  --force-delete-without-recovery
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📞 Support

For issues and questions:
- Open an issue on [GitHub](https://github.com/KUNAL-MAURYA1470/aws-ecs-rds/issues)
- Review the [Troubleshooting](#-troubleshooting) section

---

**⭐ If you find this project helpful, please consider giving it a star!**
