#!/bin/bash

function terragruntDestroy() {
	# Gather the output of `terragrunt destroy`.
	echo "destroy: info: destroying Terragrunt-managed infrastructure in ${tfWorkingDir}"
	destroyCommand="terragrunt destroy-all --terragrunt-non-interactive ${*} 2>&1"
	destroyOutput=$(eval ${destroyCommand})
	destroyExitCode=${?}

	# Exit code of 0 indicates success. Print the output and exit.
	if [ ${destroyExitCode} -eq 0 ]; then
		echo
		echo -e "${BGreen}destroy: info: successfully destroyed Terragrunt-managed infrastructure in ${tfWorkingDir}${NC}"
		echo "${destroyOutput}"
		echo
	else
		# Exit code of !0 indicates failure.
		echo
		echo -e "${BRed}destroy: error: failed to destroy Terragrunt configuration in ${tfWorkingDir}${NC}"
		echo "${destroyOutput}"
		echo
		exit ${destroyExitCode}
	fi
}
