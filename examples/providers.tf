terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

variable "github_token" {
  type = string
}

provider "github" {
  # GitHub token should be provided via env var GITHUB_TOKEN
  token = var.github_token
}
