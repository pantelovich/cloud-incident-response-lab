output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = aws_guardduty_detector.main.id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.auto_remediate.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.auto_remediate.arn
}

output "cloudwatch_event_rule_name" {
  description = "Name of the CloudWatch Event Rule"
  value       = aws_cloudwatch_event_rule.guardduty_findings.name
}

output "test_instance_public_ip" {
  description = "Public IP of the test instance"
  value       = var.create_test_instance ? aws_instance.test[0].public_ip : null
}

output "test_instance_id" {
  description = "ID of the test instance"
  value       = var.create_test_instance ? aws_instance.test[0].id : null
}