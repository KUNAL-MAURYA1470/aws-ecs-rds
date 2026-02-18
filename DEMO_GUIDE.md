# Project Demonstration Guide

## 📸 Screenshots to Take

### 1. **Architecture Overview**
- [ ] Upload your architecture diagram (`cloudformation-2tier.drawio.png`)

### 2. **AWS Console - VPC**
- [ ] VPC Dashboard showing your VPC
- [ ] Subnets page showing 2 public + 2 private subnets across 2 AZs
- [ ] Route Tables (public and private)
- [ ] NAT Gateway and Internet Gateway

### 3. **AWS Console - ECS**
- [ ] ECS Clusters page showing your cluster
- [ ] ECS Service details (running tasks, desired count)
- [ ] Task definition showing container configuration
- [ ] CloudWatch Logs showing container logs

### 4. **AWS Console - RDS**
- [ ] RDS Instances showing PostgreSQL database
- [ ] Database connectivity & security settings
- [ ] Secrets Manager showing the secret
- [ ] Secret rotation configuration

### 5. **AWS Console - Load Balancer**
- [ ] ALB details page
- [ ] Target Groups showing healthy targets
- [ ] Listener rules
- [ ] WAF association

### 6. **AWS Console - WAF**
- [ ] WAF Web ACL details
- [ ] Rules configured (rate limiting + AWS managed rules)
- [ ] Metrics/monitoring

### 7. **AWS Console - IAM**
- [ ] IAM Roles for ECS (task and execution roles)
- [ ] Policies attached to roles

### 8. **AWS Console - S3**
- [ ] S3 bucket created for application data

### 9. **Application Working**
- [ ] Browser showing the ALB URL with nginx welcome page
- [ ] Terminal showing `curl` command with 200 OK response

### 10. **Terraform**
- [ ] Terminal showing `terraform plan` output
- [ ] Terminal showing `terraform apply` completion
- [ ] Terminal showing `terraform output` with all values

## 🎥 Demo Flow

### Step 1: Show Architecture
```
"This is a 2-tier architecture with ECS Fargate and RDS PostgreSQL"
- Point out VPC, subnets, ECS, RDS, ALB, WAF
```

### Step 2: Show Terraform Code
```bash
# Show main.tf structure
cat main.tf

# Show modules
ls -la modules/

# Show configuration
cat terraform.tfvars.example
```

### Step 3: Show Deployed Infrastructure
```bash
# Show all resources
terraform state list

# Show outputs
terraform output
```

### Step 4: Demonstrate Working Application
```bash
# Test the endpoint
curl -I http://ecs-rds-poc-dev-alb-918533035.us-east-1.elb.amazonaws.com

# Show ECS tasks
aws ecs list-tasks --cluster ecs-rds-poc-dev-cluster --region us-east-1

# Show logs
aws logs tail /ecs/ecs-rds-poc-dev --region us-east-1
```

### Step 5: Show Database Connection
```bash
# Get RDS endpoint
terraform output rds_endpoint

# Get database credentials
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw rds_secret_arn) \
  --region us-east-1 \
  --query SecretString --output text | jq .
```

### Step 6: Show Security Features
```
- WAF protecting ALB
- RDS in private subnets
- Secrets Manager with rotation
- Encrypted storage
- Security groups
```

## 📝 Talking Points

### Infrastructure Highlights:
1. **High Availability**: Resources across 2 AZs
2. **Security**: Private subnets, WAF, encryption, secrets rotation
3. **Scalability**: Auto-scaling for ECS tasks
4. **Monitoring**: CloudWatch Logs and metrics
5. **Infrastructure as Code**: Fully automated with Terraform
6. **Modular Design**: Reusable Terraform modules

### Technical Details:
- VPC with CIDR 10.0.0.0/16
- 2 public subnets (10.0.1.0/24, 10.0.2.0/24)
- 2 private subnets (10.0.11.0/24, 10.0.12.0/24)
- ECS Fargate (serverless containers)
- RDS PostgreSQL with automated backups
- Application Load Balancer with health checks
- WAF with rate limiting (2000 req/5min)
- Secrets Manager with 30-day rotation

### Cost Optimization:
- Using t4g.micro for RDS (ARM-based, cheaper)
- Minimal ECS task size (256 CPU, 512 MB)
- Single NAT Gateway (can add more for HA)
- Estimated cost: ~$82-92/month

## 🎬 Video Demo Script

1. **Introduction** (30 sec)
   - "I've built a production-ready 2-tier architecture on AWS using Terraform"

2. **Architecture Overview** (1 min)
   - Show diagram
   - Explain components

3. **Code Walkthrough** (2 min)
   - Show Terraform structure
   - Highlight modular design
   - Show key configurations

4. **Live Demo** (2 min)
   - Show AWS Console resources
   - Test application endpoint
   - Show logs and monitoring

5. **Security & Best Practices** (1 min)
   - Highlight security features
   - Explain design decisions

6. **Conclusion** (30 sec)
   - Summary of what was built
   - Mention scalability and production-readiness

## 📋 Documentation Checklist

- [x] README.md with setup instructions
- [x] Architecture diagram
- [x] terraform.tfvars.example
- [x] .gitignore configured
- [ ] Screenshots folder with all images
- [ ] DEPLOYMENT_SUMMARY.md
- [ ] Cost breakdown document
- [ ] Security considerations document

## 🔗 GitHub Repository Structure

```
aws-ecs-rds/
├── README.md
├── DEPLOYMENT_SUMMARY.md
├── DEMO_GUIDE.md (this file)
├── .gitignore
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── lambda/
│   └── lambda_function.py
├── modules/
│   ├── vpc/
│   ├── ecs/
│   ├── rds/
│   ├── alb/
│   ├── iam/
│   └── waf/
└── screenshots/
    ├── architecture.png
    ├── vpc-subnets.png
    ├── ecs-cluster.png
    ├── rds-database.png
    ├── alb-targets.png
    ├── waf-rules.png
    └── app-working.png
```
