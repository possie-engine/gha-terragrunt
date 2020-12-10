## Customised GitHub Action for Terragrunt Operations

This repo provides two modularised github actions that are customised to meet the current DevOps requirements.

- One action is **validate-and-plan** that includes Terragrunt file formatting, validation and planning the to-be-deployed cloud infrastructure.
- One action is **deploy-and-destroy** that includes Terragrunt file formatting, applying and/or destroying the cloud infrastructure.

## Usage

This section lists the input variables, environment variables and internal trigger conditions for each github action. Code examples on how to use these github actions are also provided.

### Terragrunt Validate-and-Plan GitHub Action

This action includes total three Terragrunt commands, i.e. `terragrunt fmt` to check the formatting of Terraform/Terragrunt files, `terragrunt validate-all` to check the validation of the to-be-deployed infrastructure, `terragrunt plan-all` to return all the to-be-deployed modifications. However, not all commands are executed on any triggering conditions. Although the action as a whole is triggered by external caller, internal conditions apply on which commands are run on each trigger.

1. Environment variables

| Variable Name   | Required? | Description                                                                                                                                                                       |
| :-------------- | :-------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| WORKDIR         | No        | Terragrunt working directory.<br/> It's a relative path within a repo's root folder.<br/> Default to the root folder.                                                             |
| AWS_CREDENTIALS | Yes       | AWS credential file to manipulate AWS resources. <br/> On *nix and macOS system, it's located in `$HOME/.aws/credentials`.                                                        |
| AWS_CONFIG      | Yes       | AWS configuration file to manipulate AWS resources. <br/> On *nix and macOS system, it's located in `$HOME/.aws/config`.                                                          |
| KUBE_CONFIG     | Yes       | Kubernetes access credentials and configuration file. <br/> On *nix and macOS system, it's located in `$HOME/.kube/config`.                                                       |
| TF_MODULE_KEY   | Yes       | SSH private key to fetch Terraform modules in private repos. <br/> The corresponding public key is known as the `Deploy Key` that must be attached to the module repo in advance. |
| CR_URL          | No        | Docker container registry server url. <br/> Default to `ghcr.io` to use the github container registry.                                                                            |
| CR_USERNAME     | Yes       | Username to access the above container registry. <br/> With ghcr, this is your github's account name.                                                                             |
| CR_PWD          | Yes       | Password to access the above container registry. <br/> With ghcr, this is a personal access token with appropriate privileges attached to your github account.                    |

2. Input variables

| Variable Name  | Required? | Description                                                                                                                                                                                                                                                                                                |
| :------------- | :-------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| tf_version     | No        | Terraform Version. Terragrunt calls terraform internally, so this defines which terraform version to be used. <br/> Must be in a format like `0.14.2` or `latest`. Default to `latest`.                                                                                                                    |
| tg_version     | No        | Terragrunt Version. This defines Terragrunt version to be used, independent from terraform version. <br/> Must be in a format like `0.26.7` or `latest`. Default to `latest`.                                                                                                                              |
| tg_fmt         | No        | Boolean value to control if the `terragrunt fmt` command is executed by default. <br/> Only two values are allowed `true` or `false`. Default to `true`.                                                                                                                                                   |
| tg_plan        | No        | Boolean value to control if the `terragrunt plan-all` command is executed by default. <br/> Only two values are allowed `true` or `false`. Default to `true`. <br/> Note that the behaviour can be **overwritten** by a github tag to manually skip the plan command.                                      |
| skip_tag_regex | No        | A shell script-formatted regular expression to match a github tag. With presence of this tag, the `terragrunt plan-all` command is suppressed. <br/> It **overwrites** the behaviour defined by `tg_plan`.<br/> Default to `-skip$`, meaning a tag suffixed with `-skip` manually suppress this operation. |

3. Output variables

| Variable Name    | Description                                                                                              |
| :--------------- | :------------------------------------------------------------------------------------------------------- |
| plan_has_changes | Return if the terragrunt-described infrastructure is different from the already deployed real-world one. |
| plan             | The std output of `terragrunt plan-all`                                                                  |


4. Command Triggering Conditions

- `terragrunt validate-all` command is always executed and can NOT be suppressed. (Validation of the terragrunt files is required on any occasion)
- `terragrunt fmt` command is executed by default, but can be suppressed by the input variable `tf_fmt`.
- `terragrunt plan-all` command is executed by default, but it can be suppressed by either `tf_plan` input variable or a github tag. Tags matching the regular express in `skip_tag_regex` (default to `-skip$`) indicate suppressing this command. **Note:** The manually set tag **overwrites** the `tf_plan` variable. As long as a matching tag is present, this command is skipped, regardless of the `tf_plan` value.


5. Code Example

This action is usually used on unprotected development branches, which do NOT provision the infrastructure in the real world. It's applied to validate the terragrunt/terraform files and show plans.

**Warning:** To provision the whole stack at once so that automatic CD can be enabled, we choose to use `plan-all` in terragrunt. However, this command might exit with **ERRORS** on occasion where actually the code has **NO** errors, and give out **WRONG** plans. This is why we provide manual skipping options for this command. [Click here](https://github.com/gruntwork-io/terragrunt/issues/720#issuecomment-497888756) to learn more about the issues with this command.

**Note:** The github tag to skip the plan operation is **automatically** deleted by this action to avoid too many useless tags. However, the local tag is not deleted and should be manually deleted. Otherwise, if you use `git push --follow-tags` to sync the remote tags with the local tags, the local tag will be pushed to the remote repo again in a subsequent `git push` operation and the github action's behaviour is maintained.

```yaml
name: "Sample Validation and Planning"

on:
  push:
    tags:
      - "plan-*"

jobs:
  sample:
    name: Sample Code
    runs-on: ubuntu-latest
    steps:
      - id: checkout
        name: Checkout
        uses: actions/checkout@v2

      - name: Terragrunt File Validation and Planning
        uses: possie-engine/gha-terragrunt/validate-and-plan@latest # Use the latest version
        env:
          # Most environment variables are passed via github secrets
          WORKDIR: "development"
          AWS_CREDENTIALS: ${{ secrets.AWS_CREDENTIALS }}
          AWS_CONFIG: ${{ secrets.AWS_CONFIG }}
          KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
          TF_MODULE_KEY: ${{ secrets.DEPLOY_KEY }}
          CR_URL: "ghcr.io"
          CR_USERNAME: ${{ secrets.CR_USER_NAME }}
          CR_PWD: ${{ secrets.CR_TOKEN }}
        with:
          tf_version: "0.14.2"	# Use a specific version of terraform instead of "latest"
          tg_version: "0.26.7"  # Use a specific version of terragrunt instead of "latest"
          tg_fmt: false # Suppress the format checking step
          skip_tag_regex: "-skip$" # Match a tag pattern to skip the plan-all step
```

---

### Terragrunt Deploy-and-Destroy GitHub Action

This action includes total four Terragrunt commands, i.e. `terragrunt fmt` to check the formatting of Terraform/Terragrunt files, `terragrunt apply-all` to deploy the described infrastructure onto the real-world cloud platform, `terragrunt destroy-all` to destroy the whole infrastructure, `terragrunt output-all` to gather all the outputs of the code into a file. However, not all commands are executed on any triggering conditions. Although the action as a whole is triggered by external caller, internal conditions apply on which commands are run on each trigger.

1. Environment variables

| Variable Name   | Required? | Description                                                                                                                                                                       |
| :-------------- | :-------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| WORKDIR         | No        | Terragrunt working directory.<br/> It's a relative path within a repo's root folder.<br/> Default to the root folder.                                                             |
| AWS_CREDENTIALS | Yes       | AWS credential file to manipulate AWS resources. <br/> On *nix and macOS system, it's located in `$HOME/.aws/credentials`.                                                        |
| AWS_CONFIG      | Yes       | AWS configuration file to manipulate AWS resources. <br/> On *nix and macOS system, it's located in `$HOME/.aws/config`.                                                          |
| KUBE_CONFIG     | Yes       | Kubernetes access credentials and configuration file. <br/> On *nix and macOS system, it's located in `$HOME/.kube/config`.                                                       |
| TF_MODULE_KEY   | Yes       | SSH private key to fetch Terraform modules in private repos. <br/> The corresponding public key is known as the `Deploy Key` that must be attached to the module repo in advance. |
| CR_URL          | No        | Docker container registry server url. <br/> Default to `ghcr.io` to use the github container registry.                                                                            |
| CR_USERNAME     | Yes       | Username to access the above container registry. <br/> With ghcr, this is your github's account name.                                                                             |
| CR_PWD          | Yes       | Password to access the above container registry. <br/> With ghcr, this is a personal access token with appropriate privileges attached to your github account.                    |

2. Input variables

| Variable Name      | Required? | Description                                                                                                                                                                                                                                                               |
| :----------------- | :-------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| tf_version         | No        | Terraform Version. Terragrunt calls terraform internally, so this defines which terraform version to be used. <br/> Must be in a format like `0.14.2` or `latest`. Default to `latest`.                                                                                   |
| tg_version         | No        | Terragrunt Version. This defines Terragrunt version to be used, independent from terraform version. <br/> Must be in a format like `0.26.7` or `latest`. Default to `latest`.                                                                                             |
| tg_fmt             | No        | Boolean value to control if the `terragrunt fmt` command is executed by default. <br/> Only two values are allowed `true` or `false`. Default to `true`.                                                                                                                  |
| tg_output          | No        | Boolean value to control if the `terragrunt output-all` command is executed after `terragrunt apply-all`. <br/> For the destroy operation, this value ignored.<br/>Only two values are allowed `true` or `false`. Default to `true`.                                      |
| tg_output_dir      | No        | The above output is in JSON format and this variable defines the directory to store the JSON file. <br/> This is a relative path to the working directory(i.e., the WORKDIR envar). <br/> For the destroy operation, this value ignored. <br/> Default to `_gha_outputs`. |
| tg_output_filename | No        | The name of the above JSON file. <br/> For the destroy operation, this value ignored.<br/> Default to `terragrunt_outputs.json`.                                                                                                                                          |
| destroy_tag_regex  | No        | A shell script-formatted regular expression to match a github tag. With presence of this tag, the `terragrunt destroy-all` command is triggered. <br/> Default to `-destroy$`, meaning a tag suffixed with `-destroy` manually triggers this operation.                   |

3. Outputs

| Variable Name       | Description                                                                                                            |
| :------------------ | :--------------------------------------------------------------------------------------------------------------------- |
| artifact_output_dir | The directory that contains output json file. It's an absolute path that can be directly referred to by other actions. |
| artifact_name       | The file name of the output json file. No path is included, just a name, e.g. "outputs.json".                          |

4. Command Triggering Conditions

- `terragrunt fmt` command is executed by default, but can be suppressed by the input variable `tf_fmt`.
- `terragrunt apply-all` is triggered **ONLY** by merged pull request events. This behaviour is internally enforced to avoid accidental modifications on the real-world infrastructure, though the action itself can be triggered by external github events.
- `terragrunt output-all` is executed by default, but can be suppressed explicitly by input variable `tf_output`. It's also disabled in the `terragrunt destroy-all` operation.
- `terragrunt destroy-all` is **ONLY** executed by pushing a github tag that matches the regular expression defined in `destroy_tag_regex`. Because the destroy operation is **dangerous**, it's not only trigged manually by assigning tags, but is also managed **ONLY** by the repo administrator who has the privilege to push to the `main` branch.

5. Code Examples

This action is usually used on the protected `main` branch which ONLY the repo admin has the full access to it. Other collaborators can not push to the `main` branch. So, destroying resources can ONLY be conducted by the admin and applying resource changes are conducted by pull requests.

**Note:** The github tag to initiate the destroy operation is **automatically** deleted by this action to avoid too many useless tags. However, the local tag is not deleted and should be manually deleted. Otherwise, if you use `git push --follow-tags` to sync the remote tags with the local tags, the local tag will be pushed to the remote repo again in a subsequent `git push` operation and the github action's behaviour is maintained.

```yaml
name: "Sample"

on:
  pull_request:
    branches:
      - main
    types: [closed]
  push:
    tags:
      - "*-destroy"

jobs:
  sample:
    # Short-circuit the job if the condition does not match, though redundant.
    if: github.event.pull_request.merged == true || (github.event_name == 'push' && endsWith(github.ref, '-destroy'))
    name: Sample
    runs-on: ubuntu-latest
    steps:
      - id: checkout
        name: Checkout
        uses: actions/checkout@v2

      - id: main
        name: Terragrunt apply and destroy
        uses: possie-engine/gha-terragrunt/deploy-and-destroy@latest # Use the latest version
        env:
          WORKDIR: "development"
          AWS_CREDENTIALS: ${{ secrets.AWS_CREDENTIALS }}
          AWS_CONFIG: ${{ secrets.AWS_CONFIG }}
          KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
          TF_MODULE_KEY: ${{ secrets.DEPLOY_KEY_PRIV }}
          CR_URL: "ghcr.io"
          CR_USERNAME: ${{ secrets.CR_USER_NAME }}
          CR_PWD: ${{ secrets.CR_TOKEN }}
        with:
          tf_version: "0.14.2"	# Use a specific version of terraform instead of "latest"
          tg_version: "0.26.7"  # Use a specific version of terragrunt instead of "latest"
          tg_fmt: false # Suppress the format checking step
          destroy_tag_regex: "-destroy$" # Regex to match a tag that initiates the destroy operation

      - id: upload
        if: github.event.pull_request.merged == true
        name: Upload Output File
        uses: actions/upload-artifact@v2
        with:
          name: output
          path: ${{ steps.main.outputs.artifact_output_dir }}/**/* # Upload the output json file as an artifact
```

If you want to assign a different output directory or output file name,

```yaml
- id: main
  name: Terragrunt apply and destroy
  uses: possie-engine/gha-terragrunt/deploy-and-destroy@latest # Use the latest version
  env:
    WORKDIR: "development"
    AWS_CREDENTIALS: ${{ secrets.AWS_CREDENTIALS }}
    AWS_CONFIG: ${{ secrets.AWS_CONFIG }}
    KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
    TF_MODULE_KEY: ${{ secrets.DEPLOY_KEY_PRIV }}
    CR_URL: "ghcr.io"
    CR_USERNAME: ${{ secrets.CR_USER_NAME }}
    CR_PWD: ${{ secrets.CR_TOKEN }}
  with:
    tf_version: "0.14.2"	# Use a specific version of terraform instead of "latest"
    tg_version: "0.26.7"  # Use a specific version of terragrunt instead of "latest"
    tg_fmt: false # Suppress the format checking step
    destroy_tag_regex: "-destroy$" # Regex to match a tag that initiates the destroy operation
    tg_output_dir: "tg_output_folder" # Use a different output directory other than the default one
    tg_output_filename: "tg_output.json" # Use a different output file name other than the default one
```
