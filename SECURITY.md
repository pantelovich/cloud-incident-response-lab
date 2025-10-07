# Security Policy

## Supported Versions

This is a learning lab project. Security updates are provided as needed for educational purposes.

## Reporting a Vulnerability

This repository is designed for educational and demonstration purposes. If you discover a security vulnerability:

1. **Do not** create a public GitHub issue
2. Report sensitive issues privately to: [security@example.com](mailto:security@example.com)
3. Include details about the vulnerability and steps to reproduce
4. Allow reasonable time for response before public disclosure

## Security Considerations

### Important: Lab Environment Only

This repository is a **laboratory environment** and should **not be deployed to production** as-is. The configuration includes:

- Intentionally permissive security groups for demonstration
- Test instances with open SSH access
- Simplified IAM policies for learning purposes

### Best Practices for Production

If adapting this code for production use:

1. Implement least-privilege IAM policies
2. Use proper network segmentation
3. Enable comprehensive logging and monitoring
4. Implement proper secret management
5. Add input validation and sanitization
6. Use AWS Config for compliance monitoring

### Secrets and Sensitive Data

- Do not include real AWS credentials or secrets in this repository
- Use example values and `terraform.tfvars.example` for documentation
- Store actual secrets using AWS Secrets Manager or Parameter Store
- Never commit `.tfvars` files with real values

### Network Security

The lab environment includes intentionally open security groups for demonstration purposes. In production:

- Implement proper network ACLs
- Use private subnets for sensitive resources
- Enable VPC Flow Logs
- Implement proper ingress/egress rules

## Dependencies

We use Dependabot to monitor and update dependencies. Security updates are prioritized and should be applied promptly.

## Contact

For security-related questions or concerns, please contact: [security@example.com](mailto:security@example.com)
