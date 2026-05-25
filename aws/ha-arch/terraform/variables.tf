variable "project" {
  description = "Project name prefix for resource naming"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2023 in us-east-1)"
  type        = string
  default     = "ami-0953476d60561c955"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password (prefer TF_VAR_db_password)"
  type        = string
  sensitive   = true
}

variable "db_instance_type" {
  description = "RDS instance class (e.g. db.t3.micro)"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
}

variable "multi_az" {
  description = "Enable RDS Multi-AZ"
  type        = bool
}

variable "backup_retention_period" {
  description = "RDS backup retention in days"
  type        = number
}

variable "deletion_protection" {
  description = "Enable RDS deletion protection"
  type        = bool
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed EC2 monitoring"
  type        = bool
  default     = true
}

variable "alarm_cpu_threshold" {
  description = "CPU utilization alarm threshold (percent)"
  type        = number
  default     = 70
}
