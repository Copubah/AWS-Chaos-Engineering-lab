locals {
  common_tags = {
    Project     = var.project_name
    Environment = "development"
    ManagedBy   = "Terraform"
  }
}
