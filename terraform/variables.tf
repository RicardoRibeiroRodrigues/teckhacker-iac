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

variable "db_allocated_storage" {
  type        = number
  description = "The allocated storage in gigabytes"
  default     = 30
}

variable "db_max_allocated_storage" {
  type        = number
  description = "The max allocated storage in gigabytes"
  default     = 150
}

variable "db_engine" {
  type        = string
  description = "The database engine"
  default     = "postgres"
}