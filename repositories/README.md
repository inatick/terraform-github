# Repositories module

Manages many repositories from shared **profiles**, so that settings and
rulesets are defined once and applied to every repository that needs them. Each
repository picks the profiles it uses and can override anything. It calls the
[repository](../repository/README.md) module once per repository.

## Usage

```hcl
module "repos" {
  source = "git::https://github.com/inatick/terraform-github.git//repositories?ref=v1.1.0"

  owner            = "my-org"
  default_profiles = ["base"] # applied to every repository first

  profiles = {
    base = {
      settings = { delete_branch_on_merge = true, allow_update_branch = true }
      rulesets = {
        protect-default-branch = {
          rules = { pull_request = { required_approving_review_count = 1 } }
        }
      }
    }
    ci-gated = {
      rulesets = {
        protect-default-branch = { # same name: replaces base's version
          rules = {
            pull_request           = { required_approving_review_count = 1 }
            required_status_checks = { checks = [{ context = "ci-ok" }] }
          }
        }
      }
    }
    public-module = {
      settings = { is_private = false, has_discussions = true }
    }
  }

  repositories = {
    terraform-modules = {
      description = "OpenTofu modules"
      profiles    = ["ci-gated", "public-module"]
    }
    api-service = {
      description = "The API service"
      profiles    = ["ci-gated"]
    }
    scratch = {
      description = "Experiments"
      settings    = { has_wiki = true }                 # per-repository override
      rulesets    = { protect-default-branch = null }   # opt out of an inherited ruleset
    }
  }
}
```

Each key of `repositories` is the repository name. `settings` takes any input
of the repository module except `repository_name`, `description` and
`rulesets`. Settings that no layer sets use the repository module's defaults
(private, squash merge only, archive on destroy, and so on).

## How profiles are merged

Each repository is built from layers, applied in order. Later layers win.

| Layer | `settings` | `rulesets` |
|-------|------------|------------|
| 1. `default_profiles`, in list order | merged key by key | merged by ruleset name |
| 2. the repository's `profiles`, in list order | merged key by key | merged by name. The same name **replaces the whole ruleset**. |
| 3. the repository's own `settings` and `rulesets` | merged key by key | merged by name. `null` **removes** an inherited ruleset. |

- A layer that leaves a setting unset doesn't change it. In the example,
  `ci-gated` sets no settings, so `terraform-modules` keeps `base`'s
  `delete_branch_on_merge = true`.
- Rulesets are replaced as a whole, never merged rule by rule, so a plan
  always shows a ruleset exactly as one layer defines it. To share variants of
  a ruleset, define each variant in its own profile, as `base` and `ci-gated`
  do.
- An unknown profile name fails the plan and names the profile.

The `resolved` output shows each repository's effective configuration: the
profiles applied, the merged settings and the rulesets. Use it to review what
a profile change will do:

```bash
tofu console <<< 'module.repos.resolved["api-service"]'
```

## GitHub Free

On GitHub Free, rulesets only work on public repositories. GitHub rejects them
on private repositories with a 403 at apply time. This module looks up the
organization's plan and catches this at **plan** time instead:

- `on_unsupported_rulesets = "fail"` (default): the plan fails and names every
  private repository that has rulesets. Make the repository public, remove its
  rulesets, upgrade the plan, or use `"skip"`.
- `on_unsupported_rulesets = "skip"`: the rulesets of those repositories are
  dropped, and the `skipped_rulesets` output lists them.

Failing is the default because silently skipping would leave you thinking a
repository is protected when it isn't. Repository settings in profiles work on
every plan.

## Moving existing repositories into this module

If you already manage repositories with `module "repo"` calls, add `moved`
blocks so they aren't recreated. Recreating would **archive** them, because
`archive_on_destroy` defaults to `true`.

```hcl
moved {
  from = module.repo["api-service"].github_repository.this
  to   = module.repos.module.repository["api-service"].github_repository.this
}
```

Check that the plan says `has moved to` and doesn't create or destroy any
repository.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.8.0 |
| github | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| github | ~> 6.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| owner | The organization that owns the repositories. Its GitHub plan is looked up to check that rulesets are supported. | `string` | n/a | yes |
| repositories | Repositories to manage, keyed by repository name. Each one inherits<br/>default\_profiles, then its own profiles (later profiles win), then its own<br/>settings and rulesets. Set a ruleset to null to remove an inherited one. | <pre>map(object({<br/>    description = optional(string)<br/>    profiles    = optional(list(string), [])<br/>    # BEGIN settings-type<br/>    settings = optional(object({<br/>      archived               = optional(bool)<br/>      is_private             = optional(bool)<br/>      allow_squash_merge     = optional(bool)<br/>      allow_merge_commit     = optional(bool)<br/>      allow_rebase_merge     = optional(bool)<br/>      allow_auto_merge       = optional(bool)<br/>      allow_update_branch    = optional(bool)<br/>      delete_branch_on_merge = optional(bool)<br/>      archive_on_destroy     = optional(bool)<br/>      has_issues             = optional(bool)<br/>      has_discussions        = optional(bool)<br/>      has_projects           = optional(bool)<br/>      has_wiki               = optional(bool)<br/>      is_template            = optional(bool)<br/>      gitignore_template     = optional(string)<br/>      license_template       = optional(string)<br/>    }), {})<br/>    # END settings-type<br/>    # BEGIN shared-ruleset-type<br/>    rulesets = optional(map(object({<br/>      target      = optional(string, "branch")<br/>      enforcement = optional(string, "active")<br/>      include     = optional(list(string))<br/>      exclude     = optional(list(string), [])<br/>      bypass_actors = optional(list(object({<br/>        actor_type  = string<br/>        actor_id    = optional(number)<br/>        bypass_mode = optional(string, "always")<br/>      })), [])<br/>      # BEGIN shared-rules-type<br/>      rules = optional(object({<br/>        creation                = optional(bool)<br/>        update                  = optional(bool)<br/>        deletion                = optional(bool, true)<br/>        non_fast_forward        = optional(bool, true)<br/>        required_linear_history = optional(bool)<br/>        required_signatures     = optional(bool)<br/>        pull_request = optional(object({<br/>          required_approving_review_count   = optional(number, 1)<br/>          dismiss_stale_reviews_on_push     = optional(bool, true)<br/>          require_code_owner_review         = optional(bool, false)<br/>          require_last_push_approval        = optional(bool, false)<br/>          required_review_thread_resolution = optional(bool, true)<br/>          allowed_merge_methods             = optional(list(string))<br/>        }))<br/>        required_status_checks = optional(object({<br/>          strict                   = optional(bool, false)<br/>          do_not_enforce_on_create = optional(bool, false)<br/>          checks = list(object({<br/>            context        = string<br/>            integration_id = optional(number)<br/>          }))<br/>        }))<br/>      }), {})<br/>      # END shared-rules-type<br/>    })), {})<br/>    # END shared-ruleset-type<br/>  }))</pre> | n/a | yes |
| default\_profiles | Profiles applied to every repository, in order, before the repository's own profiles. | `list(string)` | `[]` | no |
| on\_unsupported\_rulesets | What to do when the organization is on the GitHub Free plan and a private<br/>repository has rulesets, which GitHub rejects on Free. "fail" (default)<br/>fails the plan and names the repositories. "skip" drops those rulesets. | `string` | `"fail"` | no |
| profiles | Named, reusable repository configuration. Each profile can set repository settings and rulesets. | <pre>map(object({<br/>    # BEGIN settings-type: one attribute per repository/ input, except<br/>    # repository_name, description, rulesets and deprecated inputs<br/>    # (scripts/check-type-drift.sh).<br/>    settings = optional(object({<br/>      archived               = optional(bool)<br/>      is_private             = optional(bool)<br/>      allow_squash_merge     = optional(bool)<br/>      allow_merge_commit     = optional(bool)<br/>      allow_rebase_merge     = optional(bool)<br/>      allow_auto_merge       = optional(bool)<br/>      allow_update_branch    = optional(bool)<br/>      delete_branch_on_merge = optional(bool)<br/>      archive_on_destroy     = optional(bool)<br/>      has_issues             = optional(bool)<br/>      has_discussions        = optional(bool)<br/>      has_projects           = optional(bool)<br/>      has_wiki               = optional(bool)<br/>      is_template            = optional(bool)<br/>      gitignore_template     = optional(string)<br/>      license_template       = optional(string)<br/>    }), {})<br/>    # END settings-type<br/>    # BEGIN shared-ruleset-type<br/>    rulesets = optional(map(object({<br/>      target      = optional(string, "branch")<br/>      enforcement = optional(string, "active")<br/>      include     = optional(list(string))<br/>      exclude     = optional(list(string), [])<br/>      bypass_actors = optional(list(object({<br/>        actor_type  = string<br/>        actor_id    = optional(number)<br/>        bypass_mode = optional(string, "always")<br/>      })), [])<br/>      # BEGIN shared-rules-type<br/>      rules = optional(object({<br/>        creation                = optional(bool)<br/>        update                  = optional(bool)<br/>        deletion                = optional(bool, true)<br/>        non_fast_forward        = optional(bool, true)<br/>        required_linear_history = optional(bool)<br/>        required_signatures     = optional(bool)<br/>        pull_request = optional(object({<br/>          required_approving_review_count   = optional(number, 1)<br/>          dismiss_stale_reviews_on_push     = optional(bool, true)<br/>          require_code_owner_review         = optional(bool, false)<br/>          require_last_push_approval        = optional(bool, false)<br/>          required_review_thread_resolution = optional(bool, true)<br/>          allowed_merge_methods             = optional(list(string))<br/>        }))<br/>        required_status_checks = optional(object({<br/>          strict                   = optional(bool, false)<br/>          do_not_enforce_on_create = optional(bool, false)<br/>          checks = list(object({<br/>            context        = string<br/>            integration_id = optional(number)<br/>          }))<br/>        }))<br/>      }), {})<br/>      # END shared-rules-type<br/>    })), {})<br/>    # END shared-ruleset-type<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| repositories | Map of repository name to its ID, name, URL and ruleset IDs |
| resolved | The effective configuration of each repository after merging its profiles: description, profiles applied, settings (unset settings use the repository module defaults) and rulesets |
| skipped\_rulesets | Repositories whose rulesets were dropped because on\_unsupported\_rulesets = "skip" and the organization is on GitHub Free |
<!-- END_TF_DOCS -->
