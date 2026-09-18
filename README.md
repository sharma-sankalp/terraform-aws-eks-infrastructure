# Ultimate DevOps Project AWS

This repository contains Terraform configuration for provisioning an Amazon VPC and an Amazon EKS cluster. The infrastructure code is in [`eks-install`](eks-install/).

## Terraform Layout

```text
eks-install/
├── main.tf                 # AWS provider, backend, and root modules
├── variables.tf            # Root input variables and defaults
├── outputs.tf              # Cluster, endpoint, and VPC outputs
├── backend/                # Optional S3 and DynamoDB state infrastructure
└── modules/
		├── vpc/                # VPC, subnets, gateways, routes, and NAT
		└── eks/                # EKS cluster, IAM roles, and node groups
```

## Prerequisites

Install Terraform and the AWS CLI. Configure credentials for the AWS account where the infrastructure will be deployed, and select the intended AWS region. The credentials must be allowed to create VPC, IAM, EKS, S3, and DynamoDB resources.

Before deploying, verify the active AWS identity and region:

```bash
aws sts get-caller-identity
aws configure get region
```

## Optional Remote Backend

The backend stack creates:

- An S3 bucket for Terraform state
- A DynamoDB table for state locking

Create these resources first, from `eks-install/backend`:

```bash
terraform init
terraform plan
terraform apply
```

Before initializing the main stack, update the S3 bucket name in [`eks-install/main.tf`](eks-install/main.tf) so it matches the bucket created by the backend stack. The configured DynamoDB table name must also match. Never commit Terraform state files or credentials.

## Deploy the Main Stack

From `eks-install`:

```bash
terraform init
terraform plan
terraform apply
```

The default configuration uses region `us-west-2`, three availability zones, a `10.0.0.0/16` VPC, and one EKS node group. Override values with a `terraform.tfvars` file or `-var` arguments. Useful outputs are available after deployment:

```bash
terraform output cluster_name
terraform output cluster_endpoint
terraform output vpc_id
```

Destroying the stack removes the AWS resources managed by Terraform:

```bash
terraform destroy
```
