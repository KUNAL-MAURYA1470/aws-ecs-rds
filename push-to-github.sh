#!/bin/bash

# Git Push Guide for AWS ECS-RDS Project

echo "🚀 Preparing to push to GitHub..."

# Step 1: Add all files
echo "📦 Adding files..."
git add .

# Step 2: Commit
echo "💾 Committing changes..."
git commit -m "feat: Complete ECS + RDS infrastructure with Terraform

- VPC with public/private subnets across 2 AZs
- ECS Fargate cluster with auto-scaling
- RDS PostgreSQL with Secrets Manager rotation
- Application Load Balancer with WAF
- CloudWatch Logs and S3 bucket
- Complete IAM roles and security groups
- Production-ready configuration"

# Step 3: Push
echo "⬆️  Pushing to GitHub..."
git push origin main

echo "✅ Done! Your code is now on GitHub"
echo ""
echo "📝 Next steps:"
echo "1. Add screenshots to screenshots/ directory"
echo "2. Update README.md with your name and repo URL"
echo "3. Copy architecture diagram to screenshots/architecture.png"
echo "4. Take AWS Console screenshots as per DEMO_GUIDE.md"
