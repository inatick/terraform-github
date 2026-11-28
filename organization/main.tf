# Looked up so that plans fail early if org_name does not exist.
# tflint-ignore: terraform_unused_declarations
data "github_organization" "this" {
  name = var.org_name
}

resource "github_organization_settings" "this" {
  billing_email                                                = var.settings.billing_email
  company                                                      = var.settings.company
  blog                                                         = var.settings.blog
  email                                                        = var.settings.email
  twitter_username                                             = var.settings.twitter_username
  location                                                     = var.settings.location
  name                                                         = var.settings.name
  description                                                  = var.settings.description
  has_organization_projects                                    = var.settings.has_organization_projects
  has_repository_projects                                      = var.settings.has_repository_projects
  default_repository_permission                                = var.settings.default_repository_permission
  members_can_create_repositories                              = var.settings.members_can_create_repositories
  members_can_create_public_repositories                       = var.settings.members_can_create_public_repositories
  members_can_create_private_repositories                      = var.settings.members_can_create_private_repositories
  members_can_create_internal_repositories                     = var.settings.members_can_create_internal_repositories
  members_can_create_pages                                     = var.settings.members_can_create_public_pages
  members_can_create_public_pages                              = var.settings.members_can_create_public_pages
  members_can_create_private_pages                             = var.settings.members_can_create_private_pages
  members_can_fork_private_repositories                        = var.settings.members_can_fork_private_repositories
  web_commit_signoff_required                                  = var.settings.web_commit_signoff_required
  advanced_security_enabled_for_new_repositories               = var.settings.advanced_security_enabled_for_new_repositories
  dependabot_alerts_enabled_for_new_repositories               = var.settings.dependabot_alerts_enabled_for_new_repositories
  dependabot_security_updates_enabled_for_new_repositories     = var.settings.dependabot_security_updates_enabled_for_new_repositories
  dependency_graph_enabled_for_new_repositories                = var.settings.dependency_graph_enabled_for_new_repositories
  secret_scanning_enabled_for_new_repositories                 = var.settings.secret_scanning_enabled_for_new_repositories
  secret_scanning_push_protection_enabled_for_new_repositories = var.settings.secret_scanning_push_protection_enabled_for_new_repositories
}

resource "github_team" "this" {
  for_each             = var.teams
  name                 = each.key
  description          = each.value.description
  privacy              = each.value.privacy
  notification_setting = each.value.notification_setting
  parent_team_id       = each.value.parent_team_id
  ldap_dn              = each.value.ldap_dn
}

resource "github_team_membership" "this" {
  for_each = {
    for pair in flatten([
      for team_key, team_val in var.teams : [
        for member in team_val.members : {
          team   = team_key
          member = member
        }
      ]
    ]) : "${pair.team}-${pair.member}" => pair
  }

  team_id  = github_team.this[each.value.team].id
  username = each.value.member
  role     = "member"
}

resource "github_organization_ruleset" "rulesets" {
  for_each = var.rulesets

  name        = each.key
  target      = each.value.target
  enforcement = each.value.enforcement

  conditions {
    ref_name {
      include = coalesce(each.value.include, each.value.target == "tag" ? ["~ALL"] : ["~DEFAULT_BRANCH"])
      exclude = each.value.exclude
    }

    dynamic "repository_name" {
      # Default to every repository unless repository_id is set.
      for_each = each.value.repository_id != null ? [] : [coalesce(each.value.repository_name, { include = ["~ALL"], exclude = [], protected = false })]
      content {
        include   = repository_name.value.include
        exclude   = repository_name.value.exclude
        protected = repository_name.value.protected
      }
    }

    repository_id = each.value.repository_id
  }

  dynamic "bypass_actors" {
    for_each = each.value.bypass_actors
    content {
      actor_type  = bypass_actors.value.actor_type
      actor_id    = bypass_actors.value.actor_id
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    creation                = each.value.rules.creation
    update                  = each.value.rules.update
    deletion                = each.value.rules.deletion
    non_fast_forward        = each.value.rules.non_fast_forward
    required_linear_history = each.value.rules.required_linear_history
    required_signatures     = each.value.rules.required_signatures

    dynamic "pull_request" {
      for_each = each.value.rules.pull_request == null ? [] : [each.value.rules.pull_request]
      content {
        required_approving_review_count   = pull_request.value.required_approving_review_count
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        require_code_owner_review         = pull_request.value.require_code_owner_review
        require_last_push_approval        = pull_request.value.require_last_push_approval
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
        allowed_merge_methods             = pull_request.value.allowed_merge_methods
      }
    }

    dynamic "required_status_checks" {
      for_each = each.value.rules.required_status_checks == null ? [] : [each.value.rules.required_status_checks]
      content {
        strict_required_status_checks_policy = required_status_checks.value.strict
        do_not_enforce_on_create             = required_status_checks.value.do_not_enforce_on_create

        dynamic "required_check" {
          for_each = required_status_checks.value.checks
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }
  }
}
