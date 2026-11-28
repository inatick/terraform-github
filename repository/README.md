# Repository module

Manages a single GitHub repository (visibility, merge methods, enabled
features and templates) and its rulesets. Defaults are opinionated: private,
squash-merge only, archived (not deleted) on destroy.

To apply the same configuration to many repositories, use the
[repositories](../repositories/README.md) module, which calls this one.

## Usage

```hcl
module "repo" {
  source = "git::https://github.com/inatick/terraform-github.git//repository?ref=v1.1.0"

  repository_name = "my-new-repo"
  description     = "A sample repository"
  is_private      = false

  rulesets = {
    protect-default-branch = {
      rules = {
        pull_request = { required_approving_review_count = 1 }
      }
    }
  }
}
```

Passing `null` for any setting uses its default.

## Rulesets

`rulesets` is a map of ruleset name to ruleset. Every attribute is optional:

| Attribute | Default | Notes |
|-----------|---------|-------|
| `target` | `"branch"` | `"branch"` or `"tag"`. Push rulesets aren't supported. |
| `enforcement` | `"active"` | `"active"` or `"disabled"`. `"evaluate"` needs GitHub Enterprise and isn't supported. |
| `include` | `["~DEFAULT_BRANCH"]` for branches, `["~ALL"]` for tags | Ref patterns such as `refs/heads/main` or `refs/tags/v*`. |
| `exclude` | `[]` | |
| `bypass_actors` | `[]` | `actor_type` is `Integration`, `OrganizationAdmin`, `RepositoryRole`, `Team` or `DeployKey`. `bypass_mode` defaults to `"always"`. |
| `rules` | deletion and force pushes blocked | See below. |

`rules` supports `creation`, `update`, `deletion` (default `true`),
`non_fast_forward` (default `true`, blocks force pushes),
`required_linear_history`, `required_signatures`, `pull_request` and
`required_status_checks`. `pull_request` defaults to one approving review,
stale reviews dismissed on push and conversations resolved before merging.

> [!IMPORTANT]
> On the GitHub Free plan, rulesets only work on **public** repositories.
> GitHub rejects them on private repositories with a 403. The
> [repositories](../repositories/README.md) module checks this at plan time.

Protect the default branch, require CI and allow squash merges only:

```hcl
rulesets = {
  protect-default-branch = {
    rules = {
      required_linear_history = true
      pull_request = {
        required_approving_review_count = 1
        allowed_merge_methods           = ["squash"]
      }
      required_status_checks = {
        checks = [
          # integration_id 15368 is GitHub Actions: only checks it reports count.
          { context = "ci-ok", integration_id = 15368 },
        ]
      }
    }
  }
}
```

Let a GitHub App bypass the ruleset (find the App ID on its settings page):

```hcl
rulesets = {
  protect-default-branch = {
    bypass_actors = [{ actor_type = "Integration", actor_id = 123456 }]
  }
}
```

Protect release tags from being moved or deleted:

```hcl
rulesets = {
  protect-release-tags = {
    target  = "tag"
    include = ["refs/tags/v*"]
    rules   = { update = true }
  }
}
```

## Destroying a repository

`archive_on_destroy` defaults to `true`, so removing a repository from your configuration archives it on GitHub instead of deleting it. The archived repository keeps its name: creating a repository with the same name later fails until you unarchive it (and import it) or delete it by hand. Set `archive_on_destroy = false` to delete repositories on destroy.

## Deprecated inputs

`has_branch_protection` and `branch_protection_config` are accepted but not
used. Use `rulesets` instead. They will be removed in v2.0.0.

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

| Name | Type |
| ---- | ---- |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_ruleset.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| repository\_name | The name of the repository | `string` | n/a | yes |
| allow\_auto\_merge | Whether pull requests can be set to merge automatically once requirements are met | `bool` | `false` | no |
| allow\_merge\_commit | Whether merge commits are allowed | `bool` | `false` | no |
| allow\_rebase\_merge | Whether rebase merge is allowed | `bool` | `false` | no |
| allow\_squash\_merge | Whether squash merge is allowed | `bool` | `true` | no |
| allow\_update\_branch | Whether to suggest updating pull request branches that are behind the base branch | `bool` | `false` | no |
| archive\_on\_destroy | Whether to archive the repository instead of deleting it on destroy | `bool` | `true` | no |
| archived | Whether the repository is archived | `bool` | `false` | no |
| branch\_protection\_config | Deprecated: not used; use the rulesets input instead. Will be removed in the next major release. | <pre>object({<br/>    branch                        = string<br/>    enforce_admins                = bool<br/>    allows_force_pushes           = bool<br/>    allows_deletions              = bool<br/>    required_pull_request_reviews = optional(bool)<br/>    required_status_checks        = optional(bool)<br/>  })</pre> | `null` | no |
| delete\_branch\_on\_merge | Whether head branches are deleted automatically after pull requests are merged | `bool` | `false` | no |
| description | Description of the repository | `string` | `""` | no |
| gitignore\_template | The gitignore template to use | `string` | `""` | no |
| has\_branch\_protection | Deprecated: not used; use the rulesets input instead. Will be removed in the next major release. | `bool` | `false` | no |
| has\_discussions | Whether discussions are enabled | `bool` | `true` | no |
| has\_issues | Whether issues are enabled | `bool` | `true` | no |
| has\_projects | Whether projects are enabled | `bool` | `false` | no |
| has\_wiki | Whether the wiki is enabled | `bool` | `false` | no |
| is\_private | Whether the repository is private | `bool` | `true` | no |
| is\_template | Whether the repository is a template | `bool` | `false` | no |
| license\_template | The license template to use | `string` | `""` | no |
| rulesets | Repository rulesets, keyed by ruleset name. Each ruleset targets branches<br/>(default) or tags. `include` defaults to the default branch for branch<br/>rulesets and to all tags for tag rulesets. Rulesets on private<br/>repositories need a paid GitHub plan. | <pre>map(object({<br/>    target      = optional(string, "branch")<br/>    enforcement = optional(string, "active")<br/>    include     = optional(list(string))<br/>    exclude     = optional(list(string), [])<br/>    bypass_actors = optional(list(object({<br/>      actor_type  = string<br/>      actor_id    = optional(number)<br/>      bypass_mode = optional(string, "always")<br/>    })), [])<br/>    # BEGIN shared-rules-type<br/>    rules = optional(object({<br/>      creation                = optional(bool)<br/>      update                  = optional(bool)<br/>      deletion                = optional(bool, true)<br/>      non_fast_forward        = optional(bool, true)<br/>      required_linear_history = optional(bool)<br/>      required_signatures     = optional(bool)<br/>      pull_request = optional(object({<br/>        required_approving_review_count   = optional(number, 1)<br/>        dismiss_stale_reviews_on_push     = optional(bool, true)<br/>        require_code_owner_review         = optional(bool, false)<br/>        require_last_push_approval        = optional(bool, false)<br/>        required_review_thread_resolution = optional(bool, true)<br/>        allowed_merge_methods             = optional(list(string))<br/>      }))<br/>      required_status_checks = optional(object({<br/>        strict                   = optional(bool, false)<br/>        do_not_enforce_on_create = optional(bool, false)<br/>        checks = list(object({<br/>          context        = string<br/>          integration_id = optional(number)<br/>        }))<br/>      }))<br/>    }), {})<br/>    # END shared-rules-type<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| html\_url | The URL of the repository on GitHub |
| repository\_id | The ID of the repository |
| repository\_name | The name of the repository |
| ruleset\_ids | Map of ruleset name to GitHub ruleset ID |
<!-- END_TF_DOCS -->
