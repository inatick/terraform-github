org_config = {
  name = "my-org"
  settings = {
    billing_email = "my@example.com"
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
      name         = "Protect all main branches"
      target       = "branch"
      entity_ids   = []
      rules_config = {
        required_pull_request_review = {
          dismiss_stale_reviews           = true
          require_last_push_approval      = false
          require_approving_review_count = 1
        }
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
