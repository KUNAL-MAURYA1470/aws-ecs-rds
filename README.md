# AWS ECS + RDS Infrastructure with Terraform

Production-ready 2-tier architecture deploying ECS Fargate with PostgreSQL RDS on AWS.

## 🏗️ Architecture

- **VPC**: Custom VPC with public/private subnets across 2 AZs
- **ECS Fargate**: Containerized application with auto-scaling
- **RDS PostgreSQL**: Managed database with automated backups
- **Application Load Balancer**: Internet-facing with health checks
- **WAF**: Web Application Firewall with rate limiting
- **Secrets Manager**: Automated password rotation (30 days)
- **CloudWatch**: Centralized logging and monitoring

## 📋 Prerequisites

- AWS CLI configured
- Terraform >= 1.8.0
- AWS account with appropriate permissions

## 🚀 Quick Start

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd aws-ecs-rds
```

2. **Configure variables**
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
```

3. **Deploy infrastructure**
```bash
terraform init
terraform plan
terraform apply
```

4. **Get outputs**
```bash
terraform output alb_dns_name
terraform output rds_endpoint
```

## 📁 Project Structure

```
.
├── main.tf                  # Main configuration
├── variables.tf             # Variable definitions
├── outputs.tf              # Output definitions
├── providers.tf            # Provider configuration
├── terraform.tfvars.example # Example configuration
├── lambda/                 # RDS rotation Lambda
│   └── lambda_function.py
└── modules/                # Reusable modules
    ├── vpc/               # VPC, subnets, routing
    ├── ecs/               # ECS cluster and service
    ├── rds/               # PostgreSQL database
    ├── alb/               # Application Load Balancer
    ├── iam/               # IAM roles and policies
    └── waf/               # Web Application Firewall
```

## 🔧 Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `ecs_task_image` | Docker image URI | `nginx:latest` |
| `db_instance_class` | RDS instance type | `db.t4g.micro` |
| `ecs_container_port` | Container port | `80` |

See `terraform.tfvars.example` for all options.

## 🔐 Security Features

- ✅ RDS in private subnets (no public access)
- ✅ Encrypted RDS storage
- ✅ Secrets Manager with rotation
- ✅ WAF with rate limiting
- ✅ Security groups with least privilege
- ✅ IAM roles with minimal permissions

## 💰 Cost Estimate

**POC Configuration (~$82-92/month):**
- ECS Fargate: ~$15
- RDS t4g.micro: ~$15
- ALB: ~$20
- NAT Gateway: ~$32
- Data transfer: Variable

## 📊 Monitoring

### View ECS Logs
```bash
aws logs tail /ecs/ecs-rds-poc-dev --follow --region us-east-1
```

### Check Service Health
```bash
aws ecs describe-services \
  --cluster ecs-rds-poc-dev-cluster \
  --services ecs-rds-poc-dev-svc \
  --region us-east-1
```

## 🗄️ Database Access

### Get Credentials
```bash
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw rds_secret_arn) \
  --region us-east-1 \
  --query SecretString --output text | jq .
```

### Environment Variables (ECS Tasks)
- `DB_HOST`: RDS endpoint
- `DB_PORT`: 5432
- `DB_NAME`: appdb
- `DB_USER`: app_user
- `DB_SECRET`: Full secret JSON

## 🧹 Cleanup

```bash
# Disable RDS deletion protection first
aws rds modify-db-instance \
  --db-instance-identifier ecs-rds-poc-dev-postgres \
  --no-deletion-protection \
  --apply-immediately \
  --region us-east-1

# Destroy infrastructure
terraform destroy
```

## 📸 Screenshots

See `screenshots/` directory for:
- Architecture diagram
- AWS Console views
- Application running
- Monitoring dashboards

## 🎯 Production Checklist

- [ ] Enable Multi-AZ for RDS
- [ ] Add SSL certificate to ALB
- [ ] Configure custom domain
- [ ] Increase ECS task count
- [ ] Set up CloudWatch alarms
- [ ] Configure backup retention
- [ ] Add VPC Flow Logs
- [ ] Enable AWS Config
- [ ] Set up CI/CD pipeline

## 📝 License

MIT

## 👤 Author

Your Name

## 🤝 Contributing

Pull requests are welcome!
