# Terraform Google Cloud Platform (GCP) AI agent(s)

The main purpose of this repository is to deploy various Artificial Intelligence (AI) agents who will work together to achieve
a common goal. All resources will be deployed onto Google Cloud Platform (GCP) for learning purposes.

## Development

![](./diagrams/proposed_architecture_for_gcp.png)

### Dependencies

- [gcloud](https://cloud.google.com/sdk/docs/install)
- [terraform](https://www.terraform.io/)
- [terragrunt](https://terragrunt.gruntwork.io/)
- [terraform-docs](https://terraform-docs.io/) this is required for `terraform_docs` hooks
- [pre-commit](https://pre-commit.com/)

## Prerequisites

1. Have a [Google Cloud account](https://cloud.google.com/free) account and [associated credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc#how-to).

## Usage

1. Navigate to the environment you would like to deploy,
2. Initialize the configuration with:

   ```bash
   terragrunt init
   ```

3. Plan your changes with:

   ```bash
   terragrunt plan
   ```

4. If you're happy with the changes

   ```bash
   terragrunt apply
   ```

> [!NOTE]
>
> Please note that terragrunt will create a bucket for storing the remote state. Ensure the account deploying the
> resources has the appropriate permissions to create or connect to these resources.

## Pre-Commit hooks

Git hook scripts are very helpful for identifying simple issues before pushing any changes. Hooks will run on every commit automatically pointing out issues in the code e.g. trailing whitespace.

To help with the maintenance of these hooks, [pre-commit](https://pre-commit.com/) is used, along with [pre-commit-hooks](https://pre-commit.com/#install).

Please following [these instructions](https://pre-commit.com/#install) to install `pre-commit` locally and ensure that you have run `pre-commit install` to install the hooks for this project.

Additionally, once installed, the hooks can be updated to the latest available version with `pre-commit autoupdate`.

## Documentation Generation

Code formatting and documentation for `variables` and `outputs` is generated using [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform/releases) hooks that in turn uses [terraform-docs](https://github.com/terraform-docs/terraform-docs) that will insert/update documentation. The following markers have been added to the `README.md`:

```
<!-- {BEGINNING|END} OF PRE-COMMIT-TERRAFORM DOCS HOOK --->
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7, <= 1.9.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.6.0 |
| <a name="requirement_sops"></a> [sops](#requirement\_sops) | ~> 1.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.6.0 |
| <a name="provider_sops"></a> [sops](#provider\_sops) | 1.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.ai_agent_docker_image_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_cloudbuildv2_connection.cloudbuild_github_project_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudbuildv2_connection) | resource |
| [google_secret_manager_secret.github_token_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_policy) | resource |
| [google_secret_manager_secret_version.github_token_secret_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_iam_policy.cloudbuild_service_account_iam_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [sops_file.encrypted_secrets](https://registry.terraform.io/providers/carlpett/sops/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | the environment type e.g. dev, stage, prod | `string` | n/a | yes |
| <a name="input_gcp_default_labels"></a> [gcp\_default\_labels](#input\_gcp\_default\_labels) | Labels that will be applied to all resources with a top level labels field or a labels<br>field nested inside a top level metadata field. | `map(string)` | `{}` | no |
| <a name="input_gcp_project"></a> [gcp\_project](#input\_gcp\_project) | The default project to manage resources in. | `string` | n/a | yes |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | The default region to manage resources in. | `string` | n/a | yes |
| <a name="input_gcp_zone"></a> [gcp\_zone](#input\_gcp\_zone) | The default zone to manage resources in. Generally, <br>this zone should be within the default region you specified. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_project_number"></a> [gcp\_project\_number](#output\_gcp\_project\_number) | The numeric identifier of the project. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK --->
