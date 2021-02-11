#!/bin/bash

function terragruntApply() {
	# Gather the output of `terragrunt apply`.
	echo "apply: info: applying Terragrunt configuration in ${tfWorkingDir}"
	applyCommand="terragrunt run-all apply --terragrunt-non-interactive ${*} 2>&1"
	applyOutput=$(eval ${applyCommand})
	applyExitCode=${?}

	# Exit code of 0 indicates success. Print the output and exit.
	if [ ${applyExitCode} -eq 0 ]; then
		echo
		echo -e "${BGreen}apply: info: successfully applied Terragrunt configuration in ${tfWorkingDir}${NC}"
		echo "${applyOutput}"
		echo
	else
		# Exit code of !0 indicates failure.
		echo
		echo -e "${BRed}apply: error: failed to apply Terragrunt configuration in ${tfWorkingDir}${NC}"
		echo "${applyOutput}"
		echo
		exit ${applyExitCode}
	fi
}
