terraform {
  required_version = ">= 1.0.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # Example Remote Backend Configuration
  # terraform {
  #   backend "s3" {
  #     bucket         = "my-terraform-state-bucket"
  #     key            = "environments/prod/terraform.tfstate"
  #     region         = "us-east-1"
  #     encrypt        = true
  #     dynamodb_table = "terraform-lock-table"
  #   }
  # }
}

module "organization" {
  source   = "./organization"
  org_name = "my-org"

  settings = {
    two_factor_requirement = "enabled"
    public_repo_creation   = "disabled"
  }

  teams = {
    "engineering" = {
      description = "Engineering team"
      members     = ["user1"]
    }
  }
}

module "repository" {
  source = "./repository"

  repository_name = "my-repo"
  is_private      = true
}

module "branch_protection" {
  source = "./branch_protection"

  repository_id = module.repository.repository_id
  branch        = "main"
}
