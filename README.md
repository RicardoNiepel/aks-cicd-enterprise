# Sample for AKS & GitHub Actions in an Enterprise environment

TODO

## Flow

* Deployment to Dev: each Pull request deploys into the same Azure Kubernetes Services inside the Dev environment using another (PR specific) namespace
* Deployment to QA: each push to master/merge of pull request deploys into the same AKS inside the QA environment using the same namespace
* Deployment to PreProd: only a specific team member (like dev lead, pm) can trigger this workflow
* Deployment to Prod: after each PreProd deployment the metrics of it are used for 5 minutes to decide to trigger an automatic deployment to Prod
  * use [AppInsights Annotation](https://www.wictorwilen.se/blog/announcing-application-insights-annotation-github-action/)

## Configure GitHub secrets

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
