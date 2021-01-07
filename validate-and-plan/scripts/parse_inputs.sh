#!/bin/bash

function parseInputs() {
	# Required inputs validation
	if [ "${AWS_CREDENTIALS}" != "" ]; then
		awsCredentials=${AWS_CREDENTIALS}
	else
		echo -e "${BRed}Input aws credentials cannot be empty${NC}"
		exit 1
	fi

	if [ "${AWS_CONFIG}" != "" ]; then
		awsConfig=${AWS_CONFIG}
	else
		echo -e "${BRed}Input aws config cannot be empty${NC}"
		exit 1
	fi

	if [ "${KUBE_CONFIG}" != "" ]; then
		kubeConfig=${KUBE_CONFIG}
	else
		echo -e "${BRed}Input kubernetes config cannot be empty${NC}"
		exit 1
	fi

	# Optional inputs validation
	tfWorkingDir=${WORKDIR:-.}            # Default: working directory is the root folder of the repo
	tfModuleKey=${TF_MODULE_KEY:-""}      # Default: empty
	export CR_URL=${CR_URL:-""}           # Default: empty
	export CR_USERNAME=${CR_USERNAME:-""} # Default: empty
	export CR_PWD=${CR_PWD:-""}           # Default: empty

	regex='^[0-9]+\.[0-9]+\.[0-9]+$'
	tfVersion=${INPUT_TF_VERSION} # Default value is set to latest
	if [ "${tfVersion}" != "latest" ]; then
		[[ $tfVersion =~ $regex ]]
		if [ ${?} -ne 0 ]; then
			echo -e "${BRed}Input terraform version should have format: xx.yy.zz, but received ${tfVersion}${NC}"
			exit 1
		fi
	fi

	tgVersion=${INPUT_TG_VERSION} # Default value is set to latest
	if [ "${tgVersion}" != "latest" ]; then
		[[ $tgVersion =~ $regex ]]
		if [ ${?} -ne 0 ]; then
			echo -e "${BRed}Input terragrunt version should have format: xx.yy.zz, but received ${tgVersion}${NC}"
			exit 1
		fi
	fi

	# Additional Github Context Inputs
	ghRef=${GH_REF#refs/tags/}
	skipPlanTagRegex=${INPUT_TAG_REGEX}

	# Terragrunt operation conditional variables
	tgFmt=${INPUT_TG_FMT}   # Default: conduct `terragrunt format` step
	tgPlan=${INPUT_TG_PLAN} # Default: use tag to control if `terragrunt plan-all` step should be conducted

	# Change Terragrunt planning conditional variable by tag
	[[ $ghRef =~ $skipPlanTagRegex ]]
	if [ ${?} -eq 0 ]; then
		tgPlan=false
		cleanUpTag $ghRef
	fi
}
