#!/bin/bash

function terragruntInit {
  # Gather the output of `terragrunt init`.
  echo "init: info: initializing Terragrunt configuration in ${TG_WORKDIR}"
  initOutput=$(terragrunt init -input=false ${*} 2>&1)
  initExitCode=${?}

  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${initExitCode} -eq 0 ]; then
    echo "${BGreen}init: info: successfully initialized Terragrunt configuration in ${TG_WORKDIR}${NC}"
    echo "${initOutput}"
    echo
  else
  	# Exit code of !0 indicates failure.
  	echo "${BRed}init: error: failed to initialize Terragrunt configuration in ${TG_WORKDIR}${NC}"
  	echo "${initOutput}"
  	echo
		exit ${initExitCode}
	fi
}
