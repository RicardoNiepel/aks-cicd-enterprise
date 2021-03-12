# Using GitHub Actions for AKS in an enterprise environment

This repository is a sample of how GitHub Actions can be used for Azure Kubernetes Service (AKS) in an enterprise environment.

It also leverages the following new features from [Universe 2020](https://github.blog/2020-12-08-new-from-universe-2020-dark-mode-github-sponsors-for-companies-and-more/):

* [GitHub Actions: Environments & environment protection rules](https://github.blog/changelog/2020-12-15-github-actions-environments-environment-protection-rules-and-environment-secrets-beta/)
* [GitHub Actions: Workflow visualization](https://github.blog/changelog/2020-12-08-github-actions-workflow-visualization/)

## Contents

- [Using GitHub Actions for AKS in an enterprise environment](#using-github-actions-for-aks-in-an-enterprise-environment)
  - [Contents](#contents)
  - [Typical Enterprise Requirements](#typical-enterprise-requirements)
  - [Implementation](#implementation)
  - [Configuration](#configuration)
    - [Create Environments](#create-environments)
    - [Create GitHub Application for workflow automation](#create-github-application-for-workflow-automation)
    - [Create Personal access tokens (PAT) for GitHub Container Registry access](#create-personal-access-tokens-pat-for-github-container-registry-access)
    - [Create Azure Service Principal](#create-azure-service-principal)
    - [After Infra Deployments: Store Environment Information](#after-infra-deployments-store-environment-information)
  - [Possible Improvements](#possible-improvements)
    - [App Workflow](#app-workflow)
    - [Infra Workflow](#infra-workflow)
  - [Credits](#credits)

## Typical Enterprise Requirements

Often the enterprise requirements are simply based on the requirements of a professional software development and deployment practice.

We focus on the following

* larger team working on different features at the same time
* there are specific code owners for specific areas
* multiple environments (DEV, QA, PROD)
* manual UI tests are sometimes necessary and not everything can/will be automated
* manual approval from decision makers are needed for production deployments

## Implementation

This repository implements the following for fulfilling the requirements above.
It's not comprehensive, but a good place to start.

* the entire Azure infrastructure provisioning is automated with Terraform
* the applications are containerized and packaged as Helm charts
* each environment (DEV, QA, PROD) looks exactly equal and no central components (Azure KeyVault, Azure Container Registry) are shared between
* each feature will be developed in a feature branch and pull requests (PRs) are used for merging it back to the main branch
  * each PR requires a minimum number of reviews before merging
  * each PR requires a review from the Code Owner
  * the build, test and package workflow needs to be successful
* it is possible to use the label ```Deploy to Test``` in a PR which will start a workflow to deploy the PR into a separate Kubernetes namespace into the DEV environment
* each push to master/merge of pull request deploys into the same AKS inside the QA environment using the same namespace
* only a specific team member (like dev lead, pm) can approve the release on the QA environment and trigger the workflow to deploy it into the PROD environment

For the dynamic DEV environments (per PR) the manual way of using the GitHub deployments API is used.

For the QA and PROD environments the new built-in way of GitHub environments & environment protection rules is used.

## Configuration

### Create Environments

1. Create a ```prod``` environment
   * add ```Required reviewers``` to it
   * add ```main``` as the allowed branch
2. Create a ```qa``` environment
   * add ```main``` as the allowed branch

### Create GitHub Application for workflow automation

The ```GITHUB_TOKEN```  has some protections around creating events that prevent downstream GitHub Actions workflow from triggering. 

For that reason you need to create a GitHub Application created so that you can request temporary credentials on behalf of the application inside your workflows.

Please follow the instructions fo the used [GitHub Action peter-murray/workflow-application-token-action](https://github.com/peter-murray/workflow-application-token-action).

Use ```REPO_AUTOMATION_APPLICATION_ID``` and ```REPO_AUTOMATION_APPLICATION_KEY``` for storing the output into the [GitHub Secrets](./../settings/secrets/actions).

### Create Personal access tokens (PAT) for GitHub Container Registry access

You need to create a PAT with ```read/write/delete:packages``` access to communicate with ghcr.io.

Use ```REPO_AUTOMATION_APPLICATION_ID``` and ```REPO_AUTOMATION_APPLICATION_KEY``` for storing the output into the [GitHub Secrets](./../settings/secrets/actions).

Use ```CR_PAT``` for storing it into the [GitHub Secrets](./../settings/secrets/actions).

### Create Azure Service Principal

1. Create Service Principal and assign `Owner` right to the target Azure subscription

```bash
SubscriptionID="<GUID>"

az ad sp create-for-rbac -n "GitHub workflow aks-cicd-enterprise" --role Owner --scopes /subscriptions/$SubscriptionID
```

2. Navigate to this project's settings [Secrets config page](./../settings/secrets/actions).
3. Update the secret with the name `AZURE_SUBSCRIPTION` with the following template (replace `<GUID>` accordingly):

```json
{
  "clientId": "<GUID>",
  "clientSecret": "<GUID>",
  "subscriptionId": "<GUID>",
  "tenantId": "<GUID>"
}
```

### After Infra Deployments: Store Environment Information

After you have deployed the infrastructure into DEV, QA and PROD, you need to configure a bunch of secrets - used in this situation a environment variables.

Please store the following for the DEV environment as ```Repository secrets``` and for the QA and PROD environments as ```Environment secrets```.

* AKS_NAME, # e.g. 'akscicddev-aks-b1ce1'
* AKS_RESOURCE_GROUP, e.g. 'aks_cicd_dev_rg'
* ACR, e.g. ACR = 'akscicddevacrh2ce1.azurecr.io'

## Possible Improvements

Following are some possible improvements to have a more advanced workflow.

### App Workflow

* Deployment to Dev: each pull request with a label deploys into the same Azure Kubernetes Services inside the Dev environment using another (PR specific) namespace
* Deployment to QA: each push to master/merge of pull request deploys into the same AKS inside the QA environment using the same namespace
* Deployment to PreProd: only a specific team member (like dev lead, pm) can trigger this workflow
* Deployment to Prod: after each PreProd deployment the metrics of it are used for 5 minutes to decide to trigger an automatic deployment to Prod
  * use [AppInsights Annotation](https://www.wictorwilen.se/blog/announcing-application-insights-annotation-github-action/)

### Infra Workflow

Take a look at https://github.com/jonico/auto-scaling-github-runners-kubernetes-issueops to see how IssueOps can be implemented with GitHub actions. This could be used to implement a workflow for the infrastructure deployment and have a pipeline like

```
Terraform Plan (DEV) > Manual Approval > Terraform Apply (DEV) > Terraform Plan (QA) > Manual Approval  > Terraform Apply (QA) > Terraform Plan (PROD) > Manual Approval  > Terraform Apply (PROD)
```

## Credits

A lot of the manual deployment workflows (DEV environment) is based on https://github.com/octodemo-containers/bookstore-advanced.

For the Terraform deployment https://github.com/olohmann/terraform-azure-runner is used to ease the Terraform pipeline deployments with an Azure state backend.
