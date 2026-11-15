.ONESHELL:
.PHONY: help init init-upgrade init-reconfigure plan plan-refresh summarise apply
.SILENT:

# Override per run, e.g. make COMMAND=terraform plan (a command-line value
# overrides :=). Deliberately not ?=: a stray COMMAND in the environment would
# silently change the tool.
COMMAND   := tofu
PLAN_FILE := plan.tfplan
PLAN_TXT  := plan.txt
VAR_FILE  := ../terraform.tfvars

# tfvars selection, mirroring scripts/terraform-local-plan.sh and the CI workflows.
# A stack-specific <stack_name>.tfvars (e.g. mgn/mgn.tfvars) is not auto-loaded
# by tofu, so it is passed after VAR_FILE to take precedence.
STACK_NAME  := $(notdir ${CURDIR})
CLIENT_NAME := $(notdir $(abspath ${CURDIR}/..))

ifeq (${CLIENT_NAME},_shared)
  # _shared stacks: parent terraform.tfvars + <stack_name>.tfvars
  VAR_FILES := $(wildcard ${VAR_FILE} ${STACK_NAME}.tfvars)
else ifneq ($(wildcard terraform.tfvars),)
  # Stack has its own terraform.tfvars, which tofu auto-loads
  VAR_FILES :=
else
  # Parent terraform.tfvars, plus <stack_name>.tfvars if present. The script
  # copies the parent file in instead; -var-file is equivalent here
  VAR_FILES := $(wildcard ${VAR_FILE} ${STACK_NAME}.tfvars)
endif

VAR_ARGS := $(addprefix -var-file=,${VAR_FILES})

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\033[36m\1\\033[m:\2/' | column -c2 -t -s :)\n"

init: ## init (COMMAND=tofu by default)
	${COMMAND} init

init-upgrade: ## init -upgrade
	${COMMAND} init -upgrade

init-reconfigure: ## init -reconfigure
	${COMMAND} init -reconfigure

plan: ## plan -> plan.tfplan (local use, -lock=false)
	# -detailed-exitcode: 0 = no changes, 1 = error, 2 = changes present. Only 1 fails.
	${COMMAND} plan -out ${PLAN_FILE} ${VAR_ARGS} -input=false -compact-warnings -lock=false -detailed-exitcode || [ $$? -eq 2 ]

plan-refresh: ## refresh-only plan -> plan.tfplan (drift detection)
	# -detailed-exitcode: 2 = drift found, which is a result, not a failure.
	${COMMAND} plan -refresh-only -out ${PLAN_FILE} ${VAR_ARGS} -input=false -compact-warnings -lock=false -detailed-exitcode || [ $$? -eq 2 ]

summarise: ## concise summary of plan.tfplan
	if [ -f ${PLAN_FILE} ]; then
		printf "Using ${PLAN_FILE}\n"
		${COMMAND} show -no-color ${PLAN_FILE} > ${PLAN_TXT} || exit 1

		# sed -n 's/X$$//p' prints only lines ending in X, with X stripped, and
		# exits 0 when nothing matches, so an empty section is not an error.
		printf ">> Created\033[0;32m\n"
		sed -n 's/ will be created$$//p' ${PLAN_TXT}
		printf "\033[0m"

		printf ">> Imported\033[0;36m\n"
		sed -n 's/ will be imported$$//p' ${PLAN_TXT}
		printf "\033[0m"

		printf ">> Destroyed\033[0;31m\n"
		sed -n 's/ will be destroyed$$//p' ${PLAN_TXT}
		printf "\033[0m"

		printf ">> Not destroyed\033[38;5;166m\n"
		sed -n 's/ will be removed from the OpenTofu state but will not be destroyed$$//p' ${PLAN_TXT}
		printf "\033[0m"

		printf ">> Changed\033[0;33m\n"
		sed -n 's/ will be updated in-place$$//p' ${PLAN_TXT}
		printf "\033[0m"

		printf ">> Replaced\n"
		sed -n 's/ must be replaced$$//p' ${PLAN_TXT}

		printf ">> Moved\n"
		sed -n '/ has moved to /p' ${PLAN_TXT}
	else
		printf "Run \"make plan\" first\n" >&2
		exit 1
	fi

apply: ## apply plan.tfplan, write output.json
	${COMMAND} apply ${PLAN_FILE}
	${COMMAND} output -json > output.json
