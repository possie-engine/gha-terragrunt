#!/bin/bash

# The folder to save the downloaded binaries
export PATH=~/bin:$PATH

function installTerraform {
	# Get the appropriate terraform version
  if [[ "${tfVersion}" == "latest" ]]; then
    echo "Checking the latest version of Terraform"
    tfVersion=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].version' | grep -v '[-].*' | sort -rV | head -n 1)

    if [[ -z "${tfVersion}" ]]; then
      echo -e "${BRed}Failed to fetch the latest version${NC}"
      exit 1
    fi
	else
		echo "Using the input version of Terraform: ${tfVersion}"
  fi

  url="https://releases.hashicorp.com/terraform/${tfVersion}/terraform_${tfVersion}_linux_amd64.zip"

  echo "Downloading Terraform v${tfVersion}"
  curl -s -S -L -o /tmp/terraform_${tfVersion} ${url}
  if [ "${?}" -ne 0 ]; then
    echo -e "${BRed}Failed to download Terraform v${tfVersion}${NC}"
    exit 1
  fi
  echo -e "${BGreen}Successfully downloaded Terraform v${tfVersion}${NC}"

  echo "Unzipping Terraform v${tfVersion}"
	unzip -d ~/bin /tmp/terraform_${tfVersion} &> /dev/null
  if [ "${?}" -ne 0 ]; then
    echo -e "${BRed}Failed to unzip Terraform v${tfVersion}${NC}"
    exit 1
  fi
  echo -e "${BGreen}Successfully unzipped Terraform v${tfVersion}${NC}"
}

function installTerragrunt {
  if [[ "${tgVersion}" == "latest" ]]; then
    echo "Checking the latest version of Terragrunt"
    latestURL=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/gruntwork-io/terragrunt/releases/latest)
    tgVersion=${latestURL##*/}

    if [[ -z "${tgVersion}" ]]; then
      echo -e "${BRed}Failed to fetch the latest version${NC}"
      exit 1
    fi
	else
		echo "Using the input version of Terragrunt: ${tgVersion}"
  fi

  url="https://github.com/gruntwork-io/terragrunt/releases/download/${tgVersion}/terragrunt_linux_amd64"

  echo "Downloading Terragrunt ${tgVersion}"
  curl -s -S -L -o /tmp/terragrunt ${url}
  if [ "${?}" -ne 0 ]; then
    echo -e "${BRed}Failed to download Terragrunt ${tgVersion}${NC}"
    exit 1
  fi
  echo -e "${BGreen}Successfully downloaded Terragrunt ${tgVersion}${NC}"

	echo "Moving Terragrunt ${tgVersion} to PATH"
  chmod +x /tmp/terragrunt
  mv /tmp/terragrunt ~/bin/terragrunt
  if [ "${?}" -ne 0 ]; then
    echo -e "${BRed}Failed to move Terragrunt ${tgVersion}${NC}"
    exit 1
  fi
  echo -e "${BGreen}Successfully moved Terragrunt ${tgVersion}${NC}"
}
