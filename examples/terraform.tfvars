org_config = {
  name = "my-org"
  settings = {
    two_factor_requirement = true
    public_repo_creation   = "DISABLED"
  }
  teams = {
    "engineering" = {
      description = "The core engineering team"
      members     = ["alice", "bob"]
    }
    "product" = {
      description = "Product management team"
      members     = ["charlie"]
    }
  }
  projects = ["Project Alpha", "Project Beta"]
  organization_rulesets = {
    "main-rule" = {
      name       = "Protect all main branches"
      target     = "organization"
      entity_ids = []
      rules_config = {
        # Placeholder for complex rules logic
      }
    }
  }
}

repositories = {
  "my-app-repo" = {
    name        = "my-app-repo"
    description = "The main application repository"
    is_private  = true
    branch_protection = {
      branch = "main"
      required_pull_request_reviews = {
        required_approving_review_count = 2
      }
    }
  }
}
