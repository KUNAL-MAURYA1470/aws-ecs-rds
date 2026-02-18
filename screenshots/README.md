# Screenshots Directory

Place your demonstration screenshots here:

## Required Screenshots:

1. **architecture.png** - Your architecture diagram
2. **vpc-subnets.png** - VPC with subnets in AWS Console
3. **ecs-cluster.png** - ECS cluster and service
4. **ecs-tasks.png** - Running ECS tasks
5. **rds-database.png** - RDS PostgreSQL instance
6. **secrets-manager.png** - Secrets Manager with rotation
7. **alb-targets.png** - ALB with healthy targets
8. **waf-rules.png** - WAF configuration
9. **app-working.png** - Browser showing working application
10. **terraform-output.png** - Terraform outputs

## How to Take Screenshots:

### AWS Console:
1. Navigate to each service
2. Take clear screenshots showing key configurations
3. Ensure sensitive data is hidden/blurred

### Terminal:
```bash
# Terraform outputs
terraform output

# ECS status
aws ecs describe-services --cluster ecs-rds-poc-dev-cluster --services ecs-rds-poc-dev-svc --region us-east-1

# Test application
curl -I http://ecs-rds-poc-dev-alb-918533035.us-east-1.elb.amazonaws.com
```

### Browser:
- Open ALB URL
- Show nginx welcome page
- Take screenshot
