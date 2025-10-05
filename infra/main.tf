terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# GuardDuty Detector
resource "aws_guardduty_detector" "main" {
  enable = true
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-incident-alerts"
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:StopInstances",
          "ec2:DescribeInstances",
          "ec2:ModifyInstanceAttribute"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.alerts.arn
      },
      {
        Effect = "Allow"
        Action = [
          "guardduty:GetFindings"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "auto_remediate" {
  function_name = "${var.project_name}-auto-remediate"
  filename      = "../lambda.zip"
  handler       = "handler.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 60

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy
  ]
}

# CloudWatch Event Rule for GuardDuty findings
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "${var.project_name}-guardduty-findings"
  description = "Capture GuardDuty findings"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.auto_remediate.arn
}

# Lambda Permission for CloudWatch Events
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_remediate.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty_findings.arn
}

# VPC for testing
resource "aws_vpc" "test_vpc" {
  count                = var.create_test_vpc ? 1 : 0
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-test-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "test_igw" {
  count  = var.create_test_vpc ? 1 : 0
  vpc_id = aws_vpc.test_vpc[0].id

  tags = {
    Name = "${var.project_name}-test-igw"
  }
}

# Public Subnet
resource "aws_subnet" "test_public" {
  count                   = var.create_test_vpc ? 1 : 0
  vpc_id                  = aws_vpc.test_vpc[0].id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-test-public"
  }
}

# Route Table
resource "aws_route_table" "test_public" {
  count  = var.create_test_vpc ? 1 : 0
  vpc_id = aws_vpc.test_vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw[0].id
  }

  tags = {
    Name = "${var.project_name}-test-public"
  }
}

# Route Table Association
resource "aws_route_table_association" "test_public" {
  count          = var.create_test_vpc ? 1 : 0
  subnet_id      = aws_subnet.test_public[0].id
  route_table_id = aws_route_table.test_public[0].id
}

# Security Group for test instance
resource "aws_security_group" "test_instance" {
  count       = var.create_test_vpc ? 1 : 0
  name        = "${var.project_name}-test-instance-sg"
  description = "Security group for test instance"
  vpc_id      = aws_vpc.test_vpc[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-test-instance-sg"
  }
}

# Test EC2 Instance
resource "aws_instance" "test" {
  count                  = var.create_test_instance ? 1 : 0
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.test_public[0].id
  vpc_security_group_ids = [aws_security_group.test_instance[0].id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nmap
  EOF

  tags = {
    Name = "${var.project_name}-test-instance"
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}