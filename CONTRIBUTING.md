# Contributing

Thank you for your interest in contributing to this cloud incident response lab!

## Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test your changes: `make test`
5. Commit your changes: `git commit -m "Add your feature"`
6. Push to your fork: `git push origin feature/your-feature-name`
7. Create a Pull Request

## Development Guidelines

### Terraform
- Run `pre-commit install` once, and ensure hooks pass before committing
- Put Terraform configuration under `infra/`
- Keep provider versions pinned in `main.tf`
- For tfsec findings that are intentional, document justification in `.tfsec.yml`
- Use `make plan` to verify changes before applying

### Code Quality
- Ensure all Terraform files are properly formatted: `terraform fmt`
- Validate Terraform configuration: `terraform validate`
- Run TFLint to check for best practices: `tflint`
- Address any security findings from tfsec

### Documentation
- New features should include screenshots in `/docs` where relevant
- Update README.md if adding new functionality
- Keep variable descriptions clear and helpful
- Document any breaking changes

### Testing
- Test locally using the sample event in `tests/sample-guardduty-event.json`
- Verify Lambda function works with AWS Console test events
- Ensure all outputs are working as expected

## Pull Request Process

1. Ensure your branch is up to date with main
2. Run `make test` to verify everything works
3. Update documentation if needed
4. Add screenshots for new features
5. Request review from maintainers

## Questions?

Feel free to open an issue for any questions or suggestions!
