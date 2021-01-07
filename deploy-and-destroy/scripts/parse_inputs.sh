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
	tfVersion=${INPUT_TF_VERSION}
	if [ "${tfVersion}" != "latest" ]; then
		[[ $tfVersion =~ $regex ]]
		if [ ${?} -ne 0 ]; then
			echo -e "${BRed}Input terraform version should have format: xx.yy.zz, but received ${tfVersion}${NC}"
		fi
	fi

	tgVersion=${INPUT_TG_VERSION}
	if [ "${tgVersion}" != "latest" ]; then
		[[ $tgVersion =~ $regex ]]
		if [ ${?} -ne 0 ]; then
			echo -e "${BRed}Input terragrunt version should have format: xx.yy.zz, but received ${tgVersion}${NC}"
		fi
	fi

	# Additional Github Context Inputs
	ghWorkSpace=${GH_WORKSPACE}
	ghEventName=${GH_EVENT_NAME}
	ghRef=${GH_REF#refs/tags/}
	ghIsPrMerge=${GH_IS_PR_MERGE}

	# Terragrunt operation conditional variables
	tgFmt=${INPUT_TG_FMT}                        # Default: conduct `terragrunt format` step
	tgOutput=${INPUT_TG_OUTPUT}                  # Default: conduct `terragrunt output-all` step
	tgOutputDir=${INPUT_TG_OUTPUT_DIR}           # Output artifact directory
	tgOutputFileName=${INPUT_TG_OUTPUT_FILENAME} # Output artifact name
	tgApply=false                                # Default: don't apply
	tgDestroy=false                              # Default: don't destroy

	# Terragrunt apply step condition (triggered only by merged pull request)
	if [ ${ghEventName} == "pull_request" ] && [ ${ghIsPrMerge} == true ]; then
		tgApply=true
	fi

	# Terragrunt destroy step condition (triggered only by pushing a matched tag)
	tgDestroyTriggerTagRegex=${INPUT_DESTROY_TAG_REGEX}
	[[ $ghRef =~ $tgDestroyTriggerTagRegex ]]
	if [ ${ghEventName} == "push" ] && [ ${?} -eq 0 ]; then
		tgDestroy=true
		tgOutput=false # Don't output anything on destroy
		cleanUpTag $ghRef
	fi
}
