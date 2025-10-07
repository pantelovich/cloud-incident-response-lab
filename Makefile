.PHONY: init plan apply destroy zip test clean

# Terraform commands
init:
	terraform -chdir=infra init

plan:
	terraform -chdir=infra plan

apply:
	terraform -chdir=infra apply -auto-approve

destroy:
	terraform -chdir=infra destroy -auto-approve

# Lambda packaging
zip:
	cd lambda && zip -r ../lambda.zip .

# Testing
test: zip
	cd infra && terraform plan

# Cleanup
clean:
	rm -f lambda.zip
	rm -rf infra/.terraform
	rm -rf infra/.terraform.lock.hcl