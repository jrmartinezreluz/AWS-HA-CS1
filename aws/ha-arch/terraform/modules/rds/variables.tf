variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "ec2_security_group_id" {
  description = "EC2 security group allowed to connect to RDS"
  type        = string
}

variable "db_instance_type" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "engine_version" {
  default = "8.0"
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "deletion_protection" {
  type    = bool
  default = false
}
