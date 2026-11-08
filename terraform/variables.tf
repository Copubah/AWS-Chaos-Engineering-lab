variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "aws-resilience-lab"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 2
}

variable "allowed_cidr" {
  description = "Allowed application access CIDR"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}
variable "notification_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
  default     = ""
}
