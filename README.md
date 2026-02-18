# AWS ECS + RDS Infrastructure

A production-ready 2-tier architecture deploying containerized applications on ECS Fargate with PostgreSQL RDS.

## Architecture

This setup includes:
- Custom VPC with public/private subnets across 2 availability zones
- ECS Fargate cluster with auto-scaling
- PostgreSQL RDS instance with automated backups
- Application Load Balancer with HTTP/HTTPS support
- ECR repository for container images
- WAF for web application protection
- Secrets Manager with automatic password rotation
- CloudWatch logging and monitoring

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.8.0
- Docker (for building and pushing images)

## Getting Started

1. **Configure your variables**

Edit `terraform.tfvars` with your desired settings:

```hcl
aws_region   = "us-east-1"
project_name = "my-app"
environment  = "prod"

ecs_task_image = "nginx:latest"  # Replace with your ECR image
```

2. **Deploy the infrastructure**

```bash
terraform init
terraform plan
terraform apply
```

3. **Push your Docker image to ECR**

```bash
# Get ECR repository URL
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Build and push your image
docker build -t my-app .
docker tag my-app:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

4. **Update ECS to use your image**

Update `ecs_task_image` in `terraform.tfvars` with your ECR URL, then:

```bash
terraform apply
```

## Project Structure

```
.
├── main.tf                  # Main configuration
├── variables.tf             # Variable definitions
├── outputs.tf              # Output definitions
├── providers.tf            # Provider configuration
├── terraform.tfvars        # Your configuration values
├── lambda/                 # RDS rotation Lambda
│   └── lambda_function.py
└── modules/                # Reusable modules
    ├── vpc/               # VPC, subnets, routing
    ├── ecs/               # ECS cluster and service
    ├── rds/               # PostgreSQL database
    ├── alb/               # Application Load Balancer
    ├── ecr/               # Container registry
    ├── iam/               # IAM roles and policies
    └── waf/               # Web Application Firewall
```

## Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `project_name` | Project name prefix | `ecs-rds-app` |
| `environment` | Environment name | `prod` |
| `ecs_task_image` | Docker image URI | Required |
| `db_instance_class` | RDS instance type | `db.t4g.micro` |
| `ecs_container_port` | Container port | `80` |

See `terraform.tfvars.example` for all available options.

## Security Features

- RDS in private subnets (no public access)
- Encrypted RDS storage
- Secrets Manager with automatic rotation
- WAF with rate limiting and AWS managed rules
- Security groups with least privilege access
- IAM roles with minimal permissions

## Monitoring

### View ECS Logs
```bash
aws logs tail /ecs/your-project-name --follow --region us-east-1
```

### Check Service Health
```bash
aws ecs describe-services \
  --cluster your-cluster-name \
  --services your-service-name \
  --region us-east-1
```

## Database Access

### Get Credentials
```bash
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw rds_secret_arn) \
  --region us-east-1 \
  --query SecretString --output text | jq .
```

The RDS credentials are automatically injected into ECS tasks as environment variables:
- `DB_HOST`: RDS endpoint
- `DB_PORT`: 5432
- `DB_NAME`: Database name
- `DB_USER`: Database username
- `DB_SECRET`: Full secret JSON

## Cleanup

```bash
terraform destroy
```

Note: If RDS has deletion protection enabled, disable it first:

```bash
aws rds modify-db-instance \
  --db-instance-identifier your-db-identifier \
  --no-deletion-protection \
  --apply-immediately \
  --region us-east-1
```

## Cost Estimate

Approximate monthly costs (us-east-1):
- ECS Fargate (1 task, 0.25 vCPU, 0.5 GB): ~$15
- RDS db.t4g.micro (20 GB storage): ~$15
- Application Load Balancer: ~$20
- NAT Gateway: ~$32
- Data transfer: Variable

**Total: ~$82-92/month** (excluding data transfer)

## License

MIT
