variable "bucket" {
    description = "Name of s3 backend"
    default = "terraform-eks-state-s3-bucket"
    type = string
}

variable "dynamodb_table" {
    description = "Name of DynamoDB table"
    default = "terraform-eks-state-locks"
    type = string
  
}