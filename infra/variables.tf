variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "cloud-incident-response"
}

variable "alert_email" {
  description = "Email address for SNS alerts"
  type        = string
}

variable "create_test_vpc" {
  description = "Whether to create a test VPC"
  type        = bool
  default     = false
}

variable "create_test_instance" {
  description = "Whether to create a test EC2 instance"
  type        = bool
  default     = false
}