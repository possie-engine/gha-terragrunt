#!/bin/bash

function terragruntFmt() {
	# Eliminate `-recursive` option for Terragrunt 0.11.x.
	fmtRecursive="-recursive"
	if hasPrefix "0.11" "${tfVersion}"; then
		fmtRecursive=""
	fi

	# Gather the output of `terragrunt fmt`.
	echo "fmt: info: checking if Terraform files in ${tfWorkingDir} are correctly formatted"
	fmtCommand="terragrunt fmt -check=true -write=false -diff ${fmtRecursive} ${*} 2>&1"
	fmtOutput=$(eval ${fmtCommand})
	fmtExitCode=${?}

	# Exit code of 0 indicates success. Print the output and exit.
	if [ ${fmtExitCode} -eq 0 ]; then
		echo
		echo -e "${BGreen}fmt: info: Terraform files in ${tfWorkingDir} are correctly formatted${NC}"
		echo "${fmtOutput}"
		echo
	elif [ ${fmtExitCode} -eq 2 ]; then
		# Exit code of 2 indicates a parse error. Print the output and exit.
		echo -e "${BRed}fmt: error: failed to parse Terraform files${NC}"
		echo "${fmtOutput}"
		echo
		exit ${fmtExitCode}
	else
		# Exit code of !0 and !2 indicates failure.
		echo -e "${BRed}fmt: error: Terraform files in ${tfWorkingDir} are incorrectly formatted${NC}"
		echo "${fmtOutput}"
		echo
		echo -e "${BRed}fmt: error: the following files in ${tfWorkingDir} are incorrectly formatted${NC}"
		fmtFileList=$(terragrunt fmt -check=true -write=false -list ${fmtRecursive})
		echo "${fmtFileList}"
		echo
		exit ${fmtExitCode}
	fi
}
