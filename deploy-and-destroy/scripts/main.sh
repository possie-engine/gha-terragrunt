#!/bin/bash

function hasPrefix() {
	case ${2} in
	"${1}"*)
		true
		;;
	*)
		false
		;;
	esac
}

function cleanUpTag() {
	echo -e "${BPurple}Deleting the tag to start terragrunt destroy...${NC}"
	git push --delete origin $1
}

# Generate a temp dummy empty tf file in the root workdir to avoid the error:
# didn't find any terraform files in the folder (*.tf)
# This error occurs when your project contains terragrunt.hcl files only withou any terraform files
function generateDummyTfFile() {
	TMPFILE=`mktemp XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
	mv $TMPFILE $TMPFILE.tf
	# This generates a random file like: MYqjEVirAmgQd9iSUA9dXTYnRRQzd1YQ.tf
}

function main() {
	# Source the other files to gain access to their functions
	scriptDir=$(dirname ${0})
	source ${scriptDir}/colours.sh
	source ${scriptDir}/install.sh
	source ${scriptDir}/parse_inputs.sh
	source ${scriptDir}/setup_secrets.sh
	source ${scriptDir}/terragrunt_init.sh
	source ${scriptDir}/terragrunt_fmt.sh
	source ${scriptDir}/terragrunt_apply.sh
	source ${scriptDir}/terragrunt_destroy.sh
	source ${scriptDir}/terragrunt_output.sh

	# Set up environment
	echo -e "${BGreen}Start Environment Setup...${NC}"
	parseInputs
	setupSecrets
	installTerraform
	installTerragrunt
	echo -e "${BGreen}Complete Environment Setup Successfully!${NC}"
	echo
	echo -e "${BBlue}Start Terragrunt Commands...${NC}"

	# Generate a dummy tf file before initialization
	generateDummyTfFile
	# (Required) Initialize Terragrunt
	terragruntInit "${*}"
	echo -e "${BBlue}Complete Terragrunt Initialization${NC}"
	echo

	# (Optional) Terragrunt Formatting
	if [ ${tgFmt} == true ]; then
		echo -e "${BBlue}Start Terragrunt Formatting...${NC}"
		terragruntFmt "${*}"
	fi

	# (Optional) Terragrunt Apply
	if [ ${tgApply} == true ]; then
		echo -e "${BBlue}Start Terragrunt Apply...${NC}"
		terragruntApply "${*}"
	fi

	# (Optional) Terragrunt Destroy
	if [ ${tgDestroy} == true ]; then
		echo -e "${BBlue}Start Terragrunt Destroy...${NC}"
		terragruntDestroy "${*}"
	fi

	# (Optional) Terragrunt Output
	if [ ${tgOutput} == true ]; then
		echo -e "${BBlue}Start Terragrunt Output...${NC}"
		terragruntOutput "${*}"
	fi

	echo -e "${BYellow}All Steps Completed Successfully!${NC}"
}

main "${*}"
