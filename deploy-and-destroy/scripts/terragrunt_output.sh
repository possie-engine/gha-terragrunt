#!/bin/bash

function terragruntOutput() {
	# Gather the output of `terragrunt output`.
	echo "output: info: gathering all the outputs for the Terragrunt configuration in ${tfWorkingDir}"
	mkdir -p "${tgOutputDir}"
	outputCommand="terragrunt output-all -json ${*} 2>&1 >${tgOutputDir}/${tgOutputFileName}"
	outputOutput=$(eval ${outputCommand})
	outputExitCode=${?}

	# Exit code of 0 indicates success. Print the output and exit.
	if [ ${outputExitCode} -eq 0 ]; then
		echo
		echo -e "${BGreen}output: info: successfully gathered all the outputs for the Terragrunt configuration in ${tfWorkingDir}${NC}"
		echo "${outputOutput}"
		echo
		echo "::set-output name=tg_output_dir::${tgOutputDir}"
		echo "::set-output name=tg_output_file::${tgOutputFileName}"
	else
		# Exit code of !0 indicates failure.
		echo
		echo -e "${BRed}output: error: failed to gather all the outputs for the Terragrunt configuration in ${tfWorkingDir}${NC}"
		echo "${outputOutput}"
		echo
		exit ${outputExitCode}
	fi
}
