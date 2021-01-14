#!/bin/bash

function terragruntInit() {
	# Gather the output of `terragrunt init`.
	echo "init: info: initializing Terragrunt configuration in ${tfWorkingDir}"
	initCommand="terragrunt init -input=false ${*} 2>&1"
	initOutput=$(eval ${initCommand})
	initExitCode=${?}

	# Exit code of 0 indicates success. Print the output and exit.
	if [ ${initExitCode} -eq 0 ]; then
		echo -e "${BGreen}init: info: successfully initialized Terragrunt configuration in ${tfWorkingDir}${NC}"
		echo "${initOutput}"
		echo
	else
		# Exit code of !0 indicates failure.
		echo -e "${BRed}init: error: failed to initialize Terragrunt configuration in ${tfWorkingDir}${NC}"
		echo "${initOutput}"
		echo
		exit ${initExitCode}
	fi
}
