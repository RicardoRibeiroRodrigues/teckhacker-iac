# Provider configuration
provider "aws" {
  region = var.region
}

provider "github" {
  token        = var.github_token
  organization = var.organization
}