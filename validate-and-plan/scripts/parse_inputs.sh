#!/bin/bash

function parseInputs {
  # Required inputs validation
  if [ "${INPUT_AWS_CREDENTIALS}" != "" ]; then
		awsCredentials=${INPUT_AWS_CREDENTIALS}
	else
    echo "Input aws credentials cannot be empty"
    exit 1
  fi

  if [ "${INPUT_AWS_CONFIG}" != "" ]; then
		awsConfig=${INPUT_AWS_CONFIG}
	else
    echo "Input aws config cannot be empty"
    exit 1
  fi

  if [ "${INPUT_KUBE_CONFIG}" != "" ]; then
		kubeConfig=${INPUT_KUBE_CONFIG}
	else
    echo "Input kubernetes config cannot be empty"
    exit 1
  fi

	if [ "${INPUT_TF_MODULE_KEY_PRIV}" != "" ]; then
		tfModuleKeyPriv=${INPUT_TF_MODULE_KEY_PRIV}
	else
    echo "Input terraform module access ssh private key cannot be empty"
    exit 1
  fi

  if [ "${INPUT_CR_USERNAME}" != "" ]; then
		export CR_USERNAME=${INPUT_CR_USERNAME}
	else
    echo "Input container registry username cannot be empty"
    exit 1
  fi

  if [ "${INPUT_CR_PWD}" != "" ]; then
		export CR_PWD=${INPUT_CR_PWD}
	else
    echo "Input container registry password cannot be empty"
    exit 1
  fi

	# Optional inputs validation
	regex='^[0-9]+\.[0-9]+\.[0-9]+$'
	if [ "${INPUT_TF_VERSION}" != "latest" ]; then
		[[ $INPUT_TF_VERSION =~ $regex ]]
		if [ ${?} -eq 0 ]; then
			tfVersion=${INPUT_TF_VERSION}
		else
			echo "Input terraform version should have format: xx.yy.zz, but received ${TF_VERSION}"
		fi
	else
		tfVersion=${INPUT_TF_VERSION}
	fi

	if [ "${INPUT_TG_VERSION}" != "latest" ]; then
		[[ $INPUT_TG_VERSION =~ $regex ]]
		if [ ${?} -eq 0 ]; then
			tgVersion=${INPUT_TG_VERSION}
		else
			echo "Input terragrunt version should have format: xx.yy.zz, but received ${TG_VERSION}"
		fi
	else
		tgVersion=${INPUT_TG_VERSION}
	fi

	export CR_URL=${INPUT_CR_URL}
	tgFmt=${INPUT_TG_FMT}
	tgPlan=${INPUT_TG_PLAN}
	tfWorkingDir=${INPUT_WORKDIR}
}
