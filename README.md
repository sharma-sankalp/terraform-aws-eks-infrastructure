# Terraform AWS EKS Infrastructure

This portfolio project provisions an Amazon VPC and an Amazon EKS cluster using Terraform. It demonstrates practical AWS infrastructure, modular Terraform, security scanning, and automated infrastructure delivery with GitHub Actions.

## Architecture

* VPC across three Availability Zones
* Public and private subnets
* Internet Gateway and NAT Gateway routing
* Amazon EKS cluster with managed node groups
* EKS control-plane logging
* Kubernetes Secrets encryption using AWS KMS
* VPC Flow Logs
* S3 and DynamoDB for Terraform remote state and locking

## Repository Structure

```text
terraform-aws-eks-infrastructure/
├── .github/
│   └── workflows/
│       ├── plan.yaml
│       └── apply.yaml
├── .checkov.yaml
├── .trivyignore
├── terraform/
│   ├── backend/
│   ├── modules/
│   │   ├── vpc/
│   │   └── eks/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```

## Security Controls

* **Checkov** runs a selected Terraform security baseline defined in `.checkov.yaml`.
* **Trivy** scans Terraform IaC for HIGH and CRITICAL misconfigurations.
* **Gitleaks** scans the repository for committed secrets.
* EKS control-plane logging is enabled for all supported control-plane log types.
* EKS Kubernetes Secrets are encrypted using a dedicated KMS key with key rotation enabled.
* VPC Flow Logs are sent to CloudWatch Logs.
* Terraform state uses S3 encryption, versioning, and Public Access Block.
* The EKS public API endpoint is restricted to a configurable CIDR.

The `.trivyignore` file contains four intentional exceptions for the current portfolio architecture:

* AWS-managed S3 encryption instead of customer-managed KMS
* Public EKS API endpoint
* Restricted public EKS API CIDR
* Public subnet IP assignment

The Trivy HIGH/CRITICAL threshold remains enabled, so other findings fail CI.

## CI/CD Workflow

### Pull Requests

Pull requests run:

```text
Checkov
   ↓
Trivy IaC
   ↓
Gitleaks
   ↓
Terraform fmt
   ↓
Terraform init
   ↓
Terraform validate
   ↓
Terraform plan
```

The PR plan is used for review only and is not uploaded or applied automatically.

### Push to main

Changes pushed to `main` run:

```text
Checkov
   ↓
Trivy IaC
   ↓
Gitleaks
   ↓
Terraform fmt
   ↓
Terraform init
   ↓
Terraform validate
   ↓
Terraform plan
   ↓
Upload plan artifact
   ↓
Apply job
   ↓
Download exact plan
   ↓
Terraform apply
```

The `apply` job applies the exact Terraform plan artifact created by the preceding `plan` job in the same workflow run.

AWS authentication currently uses the following GitHub repository secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
```

## Remote State Setup

The backend configuration creates the S3 bucket and DynamoDB table used for Terraform remote state and state locking.

Bootstrap the backend from the repository root:

```bash
terraform -chdir=terraform/backend init
terraform -chdir=terraform/backend plan
terraform -chdir=terraform/backend apply
```

Ensure the S3 bucket and DynamoDB table configured for the main Terraform stack match the resources created by the backend configuration.

Never commit Terraform state files or credentials.

## Deployment

From the repository root:

```bash
terraform -chdir=terraform init
terraform -chdir=terraform plan
terraform -chdir=terraform apply
```

View Terraform outputs:

```bash
terraform -chdir=terraform output
```

## Manual Testing

### Terraform

```bash
terraform -chdir=terraform fmt -check -recursive
terraform -chdir=terraform init
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

### Checkov

```bash
checkov -d terraform --config-file .checkov.yaml
```

### Trivy IaC

```bash
docker run --rm \
  -v "$PWD":/workspace:ro \
  -w /workspace \
  aquasec/trivy:0.58.1 \
  config \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  terraform
```

### Gitleaks

```bash
docker run --rm \
  -v "$PWD":/repo:ro \
  -w /repo \
  zricethezav/gitleaks:v8.21.2 \
  detect \
  --source . \
  --no-banner \
  --redact \
  --exit-code 1
```

## Destroy

Destroy the infrastructure when it is no longer required:

```bash
terraform -chdir=terraform destroy
```
