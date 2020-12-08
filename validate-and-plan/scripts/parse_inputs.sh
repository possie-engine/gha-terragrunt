#!/bin/bash

function parseInputs {
  # Required inputs validation
  if [ "${AWS_CREDENTIALS}" != "" ]; then
		awsCredentials=${AWS_CREDENTIALS}
	else
    echo "${BRed}Input aws credentials cannot be empty${NC}"
    exit 1
  fi

  if [ "${AWS_CONFIG}" != "" ]; then
		awsConfig=${AWS_CONFIG}
	else
    echo "${BRed}Input aws config cannot be empty${NC}"
    exit 1
  fi

  if [ "${KUBE_CONFIG}" != "" ]; then
		kubeConfig=${KUBE_CONFIG}
	else
    echo "${BRed}Input kubernetes config cannot be empty${NC}"
    exit 1
  fi

	if [ "${TF_MODULE_KEY}" != "" ]; then
		tfModuleKey=${TF_MODULE_KEY}
	else
    echo "${BRed}Input terraform module access ssh private key cannot be empty${NC}"
    exit 1
  fi

  if [ "${CR_USERNAME}" == "" ]; then
    echo "${BRed}Input container registry username cannot be empty${NC}"
    exit 1
  fi

  if [ "${CR_PWD}" == "" ]; then
    echo "${BRed}Input container registry password cannot be empty${NC}"
    exit 1
  fi

	# Optional inputs validation
	export CR_URL=${$CR_URL:-ghcr.io}	# Default value is set to ghcr

	regex='^[0-9]+\.[0-9]+\.[0-9]+$'
	tfVersion=${TF_VERSION:-latest} # Default value is set to latest
	if [ "${tfVersion}" != "latest" ]; then
		[[ $tfVersion =~ $regex ]]
		if [ ${?} -ne 0 ]; then
			echo "${BRed}Input terraform version should have format: xx.yy.zz, but received ${tfVersion}${NC}"
		fi
	fi

	tgVersion=${TG_VERSION:-latest} # Default value is set to latest
	if [ "${tgVersion}" != "latest" ]; then
		[[ $tgVersion =~ $regex ]]
		if [ ${?} -ne 0 ]; then
			echo "${BRed}Input terragrunt version should have format: xx.yy.zz, but received ${tgVersion}${NC}"
		fi
	fi

	tgFmt=${TG_FMT:-true} # Default: conduct `terragrunt format` step
	tgPlan=${TG_PLAN:-true} # Default: conduct `terragrunt plan-all` step
	tfWorkingDir=${WORKDIR:-.} # Default: working directory is the root folder of the repo
}
