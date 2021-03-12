# Using GitHub Actions for AKS in an enterprise environment <!-- omit in toc -->

This repository is a sample of how GitHub Actions can be used for Azure Kubernetes Service (AKS) in an enterprise environment.

It also leverages the following new features from [Universe 2020](https://github.blog/2020-12-08-new-from-universe-2020-dark-mode-github-sponsors-for-companies-and-more/):

* [GitHub Actions: Environments & environment protection rules](https://github.blog/changelog/2020-12-15-github-actions-environments-environment-protection-rules-and-environment-secrets-beta/)
* [GitHub Actions: Workflow visualization](https://github.blog/changelog/2020-12-08-github-actions-workflow-visualization/)

## Contents <!-- omit in toc -->

- [Typical Enterprise Requirements](#typical-enterprise-requirements)
- [Implementation](#implementation)
- [Walk-through](#walk-through)
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

We focus in this sample on the following

* larger team working on different features at the same time
* there are specific code owners for specific areas
* multiple environments (DEV, QA, PROD)
* manual UI tests are sometimes necessary and not everything can/will be automated
* manual approval from decision makers are needed for production deployments

## Implementation

This repository implements the following for fulfilling the requirements above.

As always it is just a sample and needs to be adjusted for product/project specific requirements.  
But it a definitely a good place to start.

* the entire Azure infrastructure provisioning is automated with [Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
* the applications are containerized and packaged as [Helm charts](https://helm.sh/)
* each environment (DEV, QA, PROD) looks exactly equal and  
  no central components (Azure KeyVault, Azure Container Registry) are shared between
* each feature will be developed in a feature branch and  
  pull requests (PRs) are used for merging it back to the main branch
  * each PR requires a minimum number of reviews before merging
  * each PR requires a review from the Code Owner
  * the build, test and package workflow needs to be successful
* it is possible to use the label ```Deploy to Test``` in a PR  
  which will start a workflow to deploy the PR into a separate Kubernetes namespace into the DEV environment
* each push to ```main```/merge of pull request  
  deploys into the same AKS inside the QA environment using the same namespace
* only a specific team member (like dev lead, pm) can approve the release on the QA environment and  
  trigger the workflow to deploy it into the PROD environment

For the dynamic DEV environments (per PR) the manual way of using the GitHub deployments API is used.

For the QA and PROD environments the new built-in way of GitHub environments & environment protection rules is used.

## Walk-through

1. Look at the ```CODEOWNERS``` file and the owner of ```application/pom.xml```
2. Inspect the infra deployment files at ```infrastructure/``` including the wrapper ```tf.ps1```
3. Look into the workflow ```.github/workflows/other_deploy_infra_environment.yaml``` and see how it can be manually be triggered
4. Navigate to ```application/src/main/webapp/books.html``` and change something, make sure to commit this change into a new branch like ```RicardoNiepel-patch-1``` and create a PR for it
5. See how the ```Branch - Build & Test App``` was triggered and executed as required checks
   1. Take a look into the ```Branch protection rules``` and see the required status checks to pass before merging
   2. Look into ```.github/workflows/branch_build_test_app.yaml``` and see the last two steps: GHCR and Status
6. Label the PR with ```Deploy to Test``` and see how the bot starts the workflow
   1. Look into ```.github/workflows/branch_create_app_deployment_by_label.yaml``` and the ```.github/workflows/scripts/``` folder
   2. Recognize another workflow was triggered: ```Branch - Deploy App to PR Environment```, look into it and also the file ```.github/workflows/branch_deploy_app_dev_pr_env.yaml```
   3. See also inside the PR the published deployment URL which we can use to test the PR
   4. Go to ```aks-cicd-enterprise/deployments``` to see a dynamic Environment was created
   5. Merge the PR and see how the deployment is marked as inactive
   6. See how two different workflows are started ```Branch - Cleanup PR Environments``` and ```Prod - Build, Test & Deploy App```
7. Look into ```Branch - Undeploy App``` and how it deletes the PR environment
   1. Refresh the old URL to see it was deleted
8. Look into ```Prod - Build, Test & Deploy App```
   1. See at ```.github/workflows/prod_build_test_deploy_app.yaml``` how it uses the environment name and url field
   2. Wait for QA be deployed, look into it and approve prod
   3. Show the deployments overview

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

After you have deployed the infrastructure into DEV, QA and PROD, you need to configure a bunch of secrets - used in this situation as environment specific variables.

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
