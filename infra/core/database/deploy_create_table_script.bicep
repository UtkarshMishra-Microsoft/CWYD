@description('Specifies the location for resources.')
param solutionLocation string

param baseUrl string
param identity string
param postgresSqlServerName string
param webAppPrincipalName string
param adminAppPrincipalName string
param managedIdentityName string
param functionAppPrincipalName string
param storageAccountName string

resource create_index 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  kind:'AzureCLI'
  name: 'create_postgres_table'
  location: solutionLocation // Replace with your desired location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity}' : {}
    }
  }
  properties: {
    azCliVersion: '2.52.0'
    primaryScriptUri: '${baseUrl}scripts/run_create_table_script.sh'
    arguments: '${baseUrl} ${resourceGroup().name} ${postgresSqlServerName} ${webAppPrincipalName} ${adminAppPrincipalName} ${functionAppPrincipalName} ${managedIdentityName}' // Specify any arguments for the script
    timeout: 'PT1H' // Specify the desired timeout duration
    retentionInterval: 'PT1H' // Specify the desired retention interval
    cleanupPreference:'OnSuccess'
    storageAccountSettings: {
      storageAccountName: storageAccountName
    }
  }
}

// Reference to the existing storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
  scope: resourceGroup()
}

// Role assignment for user-assigned managed identity to access storage account
resource createIndexRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.id, identity, 'StorageBlobDataContributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: reference(identity, '2023-01-31').principalId
    principalType: 'ServicePrincipal'
  }
}
