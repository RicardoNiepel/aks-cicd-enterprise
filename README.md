# Sample for AKS & GitHub Actions in an Enterprise environment

TODO

## Configure GitHub secrets

1. Create Service Principal and assign `Owner` right to the target Azure subscription

```bash
SubscriptionID="<GUID>"

az ad sp create-for-rbac -n "GitHub workflow aks-cicd-enterprise" --role Owner --scopes /subscriptions/$SubscriptionID
```

2. Navigate to this project's settings [Secrets config page](./../settings/secrets/actions).
3. Update the secret with the name `AZURE_PROD` with the following template (replace `<GUID>` accordingly):

```json
{
  "clientId": "<GUID>",
  "clientSecret": "<GUID>",
  "subscriptionId": "<GUID>",
  "tenantId": "<GUID>"
}
```
