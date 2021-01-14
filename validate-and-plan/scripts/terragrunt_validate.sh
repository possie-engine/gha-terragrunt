#!/bin/bash

function terragruntValidate() {
	# Gather the output of `terragrunt validate`.
	echo "validate: info: validating Terragrunt configuration in ${tfWorkingDir}"
	validateCommand="terragrunt validate-all ${*} 2>&1"
	validateOutput=$(eval ${validateCommand})
	validateExitCode=${?}

	# Exit code of 0 indicates success. Print the output and exit.
	if [ ${validateExitCode} -eq 0 ]; then
		echo
		echo -e "${BGreen}validate: info: successfully validated Terragrunt configuration in ${tfWorkingDir}${NC}"
		echo "${validateOutput}"
		echo
	else
		# Exit code of !0 indicates failure.
		echo
		echo -e "${BRed}validate: error: failed to validate Terragrunt configuration in ${tfWorkingDir}${NC}"
		echo "${validateOutput}"
		echo
		exit ${validateExitCode}
	fi
}
