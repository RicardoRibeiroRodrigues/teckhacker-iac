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