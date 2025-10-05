#!/bin/bash

# Cloud Incident Response Automation - Deployment Script
# This script automates the deployment process

set -e

echo "Starting Cloud Incident Response Automation deployment..."

# Check prerequisites
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed or not in PATH"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -d "infra" ] || [ ! -d "lambda" ]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

# Create lambda.zip
echo "Creating lambda deployment package..."
cd lambda
if [ -f "../lambda.zip" ]; then
    rm ../lambda.zip
fi
zip -r ../lambda.zip . > /dev/null
cd ..

# Check if terraform.tfvars exists
if [ ! -f "infra/terraform.tfvars" ]; then
    echo "Creating terraform.tfvars template..."
    cat > infra/terraform.tfvars << EOF
aws_region           = "us-east-1"
alert_email          = "your-email@example.com"
project_name         = "cloud-incident-response"
create_test_vpc      = false
create_test_instance = false
EOF
    echo "Please edit infra/terraform.tfvars with your email address before continuing"
    echo "Then run: ./deploy.sh"
    exit 0
fi

# Initialize and apply Terraform
echo "Initializing Terraform..."
cd infra
terraform init

echo "Planning Terraform deployment..."
terraform plan

echo "Applying Terraform configuration..."
read -p "Do you want to proceed with deployment? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply -auto-approve
    echo "Deployment completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Check your email and confirm the SNS subscription"
    echo "2. If you enabled test resources, note the instance IP for testing"
    echo "3. Review the outputs above for important resource information"
else
    echo "Deployment cancelled"
fi

cd ..