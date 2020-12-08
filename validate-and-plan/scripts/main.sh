#!/bin/bash

function hasPrefix {
  case ${2} in
    "${1}"*)
      true
      ;;
    *)
      false
      ;;
  esac
}

function main {
  # Source the other files to gain access to their functions
  scriptDir=$(dirname ${0})
	source ${scriptDir}/install.sh
	source ${scriptDir}/parse_inputs.sh
	source ${scriptDir}/setup_secrets.sh
	source ${scriptDir}/terragrunt_fmt.sh
  source ${scriptDir}/terragrunt_init.sh
  source ${scriptDir}/terragrunt_validate.sh
  source ${scriptDir}/terragrunt_plan.sh

  parseInputs
	setupSecrets
  installTerraform
	installTerragrunt
  # cd ${GITHUB_WORKSPACE}/${tfWorkingDir}

	# (Required) Initialize Terragrunt
	terragruntInit "${*}"
	echo "Complete tarragrunt initialization"
	# (Optional) Terragrunt Formatting
	if [ ${tgFmt} == "true" ]; then
		terragruntFmt "${*}"
	fi
	# (Required) Terragrunt Validation
	terragruntValidate "${*}"
	# (Optional) Terragrunt Planning
	if [ ${tgPlan} == "true" ]; then
		terragruntPlan "${*}"
	fi
}

main "${*}"
