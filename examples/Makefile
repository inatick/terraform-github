.ONESHELL:
.PHONY: help init plan summarise apply
.SILENT:

# Local use only: plan the example against a real organization.
# Needs GITHUB_TOKEN (and GITHUB_OWNER) in the environment.
# Override the tool per run, e.g. make COMMAND=terraform plan
COMMAND   := tofu
PLAN_FILE := plan.tfplan
PLAN_TXT  := plan.txt

help:
	@grep -hE '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

init: ## init
	${COMMAND} init

plan: ## plan -> plan.tfplan (-lock=false)
	# -detailed-exitcode: 0 = no changes, 1 = error, 2 = changes present. Only 1 fails.
	${COMMAND} plan -out ${PLAN_FILE} -input=false -compact-warnings -lock=false -detailed-exitcode || [ $$? -eq 2 ]

summarise: ## concise summary of plan.tfplan
	if [ ! -f ${PLAN_FILE} ]; then printf "Run \"make plan\" first\n" >&2; exit 1; fi
	${COMMAND} show -no-color ${PLAN_FILE} > ${PLAN_TXT} || exit 1
	printf ">> Created\n";   sed -n 's/ will be created$$//p' ${PLAN_TXT}
	printf ">> Imported\n";  sed -n 's/ will be imported$$//p' ${PLAN_TXT}
	printf ">> Destroyed\n"; sed -n 's/ will be destroyed$$//p' ${PLAN_TXT}
	printf ">> Changed\n";   sed -n 's/ will be updated in-place$$//p' ${PLAN_TXT}
	printf ">> Replaced\n";  sed -n 's/ must be replaced$$//p' ${PLAN_TXT}
	printf ">> Moved\n";     sed -n '/ has moved to /p' ${PLAN_TXT}

apply: ## apply plan.tfplan
	${COMMAND} apply ${PLAN_FILE}
