locals {
  # Profile names each repository uses, in the order they are applied.
  profile_names = {
    for name, repo in var.repositories : name => concat(var.default_profiles, repo.profiles)
  }

  unknown_profiles = sort(distinct(flatten([
    for names in values(local.profile_names) : [for p in names : p if !contains(keys(var.profiles), p)]
  ])))

  # Merge the layers in order: default profiles, the repository's profiles,
  # then the repository's own settings and rulesets. Later layers win.
  #
  # Settings are merged key by key. Unset (null) attributes are dropped from
  # each layer first, so a layer that leaves a setting unset doesn't reset a
  # value an earlier layer set. Rulesets are merged by name: a later ruleset
  # with the same name replaces the earlier one as a whole, and null removes it.
  resolved = {
    for name, repo in var.repositories : name => {
      description = repo.description
      profiles    = local.profile_names[name]
      settings = merge([
        for layer in concat(
          [for p in local.profile_names[name] : var.profiles[p].settings if contains(keys(var.profiles), p)],
          [repo.settings],
        ) : { for k, v in layer : k => v if v != null }
      ]...)
      rulesets = {
        for k, v in merge(concat(
          [for p in local.profile_names[name] : var.profiles[p].rulesets if contains(keys(var.profiles), p)],
          [repo.rulesets],
        )...) : k => v if v != null
      }
    }
  }

  # Repositories whose rulesets GitHub Free rejects. Unset is_private means
  # private, the repository module's default.
  private_with_rulesets = sort([
    for name, r in local.resolved : name
    if length(r.rulesets) > 0 && try(r.settings.is_private, true)
  ])

  on_free_plan  = lower(data.github_organization.this.plan) == "free"
  skip_rulesets = local.on_free_plan && var.on_unsupported_rulesets == "skip" ? local.private_with_rulesets : []
}

data "github_organization" "this" {
  name         = var.owner
  summary_only = true

  lifecycle {
    precondition {
      condition     = length(local.unknown_profiles) == 0
      error_message = "Unknown profile(s): ${join(", ", local.unknown_profiles)}. Every name in default_profiles and repositories[*].profiles must be a key of var.profiles."
    }

    postcondition {
      condition     = lower(self.plan) != "free" || var.on_unsupported_rulesets == "skip" || length(local.private_with_rulesets) == 0
      error_message = "The ${var.owner} organization is on the GitHub Free plan, and rulesets require GitHub Team for private repositories: ${join(", ", local.private_with_rulesets)}. Make each repository public, remove its rulesets, set on_unsupported_rulesets = \"skip\", or upgrade the plan."
    }
  }
}

module "repository" {
  source   = "../repository"
  for_each = local.resolved

  repository_name        = each.key
  description            = each.value.description
  archived               = try(each.value.settings.archived, null)
  is_private             = try(each.value.settings.is_private, null)
  allow_squash_merge     = try(each.value.settings.allow_squash_merge, null)
  allow_merge_commit     = try(each.value.settings.allow_merge_commit, null)
  allow_rebase_merge     = try(each.value.settings.allow_rebase_merge, null)
  allow_auto_merge       = try(each.value.settings.allow_auto_merge, null)
  allow_update_branch    = try(each.value.settings.allow_update_branch, null)
  delete_branch_on_merge = try(each.value.settings.delete_branch_on_merge, null)
  archive_on_destroy     = try(each.value.settings.archive_on_destroy, null)
  has_issues             = try(each.value.settings.has_issues, null)
  has_discussions        = try(each.value.settings.has_discussions, null)
  has_projects           = try(each.value.settings.has_projects, null)
  has_wiki               = try(each.value.settings.has_wiki, null)
  is_template            = try(each.value.settings.is_template, null)
  gitignore_template     = try(each.value.settings.gitignore_template, null)
  license_template       = try(each.value.settings.license_template, null)
  rulesets               = contains(local.skip_rulesets, each.key) ? {} : each.value.rulesets
}
