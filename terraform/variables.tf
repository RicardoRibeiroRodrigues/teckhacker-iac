variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "DB_USER" {
  type        = string
  description = "Database user"
}

variable "DB_PASS" {
  type        = string
  description = "Database password"
}

variable "DB_NAME" {
  type        = string
  description = "Database name"
}

variable "GUAC_PASS" {
  type        = string
  description = "Guacamole password"
}

variable "ZABBIX_PASS" {
  type        = string
  description = "Zabbix password"
}

# --------------------- Staging Env -----------------------
variable "repository_name" {
  description = "The name of the repository"
  default     = "get-it-django"
}

variable "repository_branch" {
  description = "The name of the branch"
  default     = "master"
}

variable "repository_owner" {
  description = "The name of the repository owner"
  default     = "RicardoRibeiroRodrigues"
}

variable "github_token" {
  description = "The github token"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "get-it-django-artifacts"
}

variable "env" {
  description = "Environment"
  default     = "dev"
}

variable "DB_TEST_USER" {
  type        = string
  description = "Test Database user"
}

variable "DB_TEST_PASS" {
  type        = string
  description = "Test Database password"
}

variable "organization" {
  description = "The name of the organization"
  default     = "RicardoRibeiroRodrigues"
}