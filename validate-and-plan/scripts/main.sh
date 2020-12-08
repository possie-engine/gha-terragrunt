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
	source ${scriptDir}/colours.sh
	source ${scriptDir}/install.sh
	source ${scriptDir}/parse_inputs.sh
	source ${scriptDir}/setup_secrets.sh
	source ${scriptDir}/terragrunt_fmt.sh
  source ${scriptDir}/terragrunt_init.sh
  source ${scriptDir}/terragrunt_validate.sh
  source ${scriptDir}/terragrunt_plan.sh

	echo "${BGreen}Start Environment Setup...${NC}"
  parseInputs
	setupSecrets
  installTerraform
	installTerragrunt
	echo "${BGreen}Complete Environment Setup Successfully!${NC}"
	echo
	echo "${BBlue}Start Terragrunt Commands...${NC}"
	# (Required) Initialize Terragrunt
	terragruntInit "${*}"
	echo "${BBlue}Complete Terragrunt Initialization${NC}"
	# (Optional) Terragrunt Formatting
	if [ ${tgFmt} == "true" ]; then
		echo "${BBlue}Start Terragrunt Formatting...${NC}"
		terragruntFmt "${*}"
	fi
	# (Required) Terragrunt Validation
	echo "${BBlue}Start Terragrunt Validation...${NC}"
	terragruntValidate "${*}"
	# (Optional) Terragrunt Planning
	if [ ${tgPlan} == "true" ]; then
		echo "${BBlue}Start Terragrunt Planning...${NC}"
		terragruntPlan "${*}"
	fi
	echo "${BYellow}All Steps Completed Successfully!${NC}"
}

main "${*}"
