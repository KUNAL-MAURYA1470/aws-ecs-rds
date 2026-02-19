# 🚀 AWS ECS + RDS Infrastructure - Production-Grade 2-Tier Architecture

[![Terraform](https://img.shields.io/badge/Terraform-v1.8+-623CE4?style=flat&logo=terraform)](https://www.terraform.io/) [![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=flat&logo=amazon-aws)](https://aws.amazon.com/)
>  Infrastructure as Code (IaC) for deploying containerized applications on AWS ECS Fargate with PostgreSQL RDS. Built with Terraform for scalability, security, and high availability.

---



## 🏗️ Architecture Overview

<img width="991" height="851" alt="aws_tier-2 drawio" src="https://github.com/user-attachments/assets/b30e54fe-8e97-47c9-9da5-4869a717b9fd" />


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

### Manual Cleanup 

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
### Resources Screenshot  

### VPC
<img width="941" height="71" alt="image" src="https://github.com/user-attachments/assets/26be6a4b-7d96-4f76-ad56-313472219047" />
<img width="941" height="300" alt="image" src="https://github.com/user-attachments/assets/7573d013-63da-4bbe-b216-9693bb0bba0a" />

### Subnets
<img width="941" height="156" alt="image" src="https://github.com/user-attachments/assets/779f4007-fb7d-40fa-a9b0-da668687d187" />

### Route tables
<img width="941" height="169" alt="image" src="https://github.com/user-attachments/assets/d3deef73-f67a-4eaa-b54d-1649983f8b82" />

### Internet Gateway
<img width="941" height="170" alt="image" src="https://github.com/user-attachments/assets/55deba98-0bc9-4b80-9088-1323cab07e58" />

### Elastic IP address
<img width="941" height="121" alt="image" src="https://github.com/user-attachments/assets/8bd95c94-14f4-4fe3-bf50-2aa17d589018" />

### NAT gateway
<img width="941" height="113" alt="image" src="https://github.com/user-attachments/assets/008d85a2-1db6-4d3c-8840-d6807ea13dce" />

### ECS Clusters 
<img width="941" height="146" alt="image" src="https://github.com/user-attachments/assets/10139296-0bf8-4761-975c-1973ff2b11c1" />


### ECS Service 
 <img width="941" height="198" alt="image" src="https://github.com/user-attachments/assets/de2cb5d8-2891-4889-925a-f37ff7951020" />

### Task Definitions
<img width="941" height="147" alt="image" src="https://github.com/user-attachments/assets/87fcc1a2-3379-43aa-a64d-69c06be7e2be" />

<img width="941" height="397" alt="image" src="https://github.com/user-attachments/assets/59bd03cf-cd8d-4351-b218-da1b20741ef4" />

###  RDS Instances  PostgreSQL database 

<img width="941" height="397" alt="image" src="https://github.com/user-attachments/assets/829441f7-7f02-4d24-8990-ac85bba57538" />

### Database connectivity & security settings

<img width="941" height="283" alt="image" src="https://github.com/user-attachments/assets/b4ca8568-2952-42a9-8de4-d0c5f3f7fb8e" />

<img width="941" height="170" alt="image" src="https://github.com/user-attachments/assets/be7948ec-4091-48c5-be0a-499f53ebab60" />

<img width="941" height="172" alt="image" src="https://github.com/user-attachments/assets/b9348273-ac1f-4474-8151-b2a878b9f1c0" />

### Secrets Manager 

<img width="941" height="101" alt="image" src="https://github.com/user-attachments/assets/f3a367ce-24bf-4273-9b9c-5e4a18ac949a" />

<img width="941" height="301" alt="image" src="https://github.com/user-attachments/assets/bc4052c9-01bc-4aea-902f-331ca6e57384" />

### Secret rotation configuration 

<img width="941" height="309" alt="image" src="https://github.com/user-attachments/assets/740de183-336a-4444-af0e-f90a2c23a202" />

### lamda  rotatation function  

<img width="941" height="396" alt="image" src="https://github.com/user-attachments/assets/2b74484c-777e-4ef5-b200-9fceb5680457" />

### ALB details page 

<img width="941" height="182" alt="image" src="https://github.com/user-attachments/assets/2e9f8325-0090-4605-a742-4cbf192912d2" />

### Listener rules

<img width="941" height="195" alt="image" src="https://github.com/user-attachments/assets/84a884ab-4280-47c6-81cf-b1efb4ffea85" />

### WAF

<img width="941" height="193" alt="image" src="https://github.com/user-attachments/assets/a61d5456-bb66-488f-b376-c0eacc090084" />

### Metrics/monitoring

<img width="941" height="399" alt="image" src="https://github.com/user-attachments/assets/4e490e05-3399-414f-8080-70539d638d92" />


### IAM Roles 

<img width="941" height="329" alt="image" src="https://github.com/user-attachments/assets/eaf5f3cc-5085-490d-8f4a-8a02832f1050" />

### S3 bucket

<img width="941" height="226" alt="image" src="https://github.com/user-attachments/assets/24a004c3-3208-4307-ba67-d7373ece8bb1" />

<img width="941" height="174" alt="image" src="https://github.com/user-attachments/assets/bba135a5-7c06-44b2-95da-e67610fe3d8e" />
