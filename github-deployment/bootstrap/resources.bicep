
@description('Name of the subscripion to bootstrap')
param subName string

@description('Id of the principal to grant access to the terraform storage account container')
param principalId string

resource storageBlobDataContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  scope: subscription()
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource deployStateStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'ghatestdam${subName}'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowedCopyScope: 'PrivateLink'
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: false
    isHnsEnabled: false
    isLocalUserEnabled: false
    isNfsV3Enabled: false
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
    routingPreference: {
      publishInternetEndpoints: false
      publishMicrosoftEndpoints: false
      routingChoice: 'MicrosoftRouting'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: deployStateStorage
  name: 'default'

  properties: {
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource deployStateStorageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'state'
  properties: {
    publicAccess: 'None'
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
  }
}

resource deployStateStorageContainerLock 'Microsoft.Authorization/locks@2016-09-01' = {
  name: 'deployStateStorageContainerLock'
  scope: deployStateStorageContainer
  properties:{
    level: 'CanNotDelete'
    notes: 'State storage should not be deleted.'
  }
}

resource deployStateStorageContainerStorageBlobDataContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(deployStateStorageContainer.id, 'ado-principal')
  scope: deployStateStorageContainer
  properties: {
    principalId: principalId
    roleDefinitionId: storageBlobDataContributorRoleDefinition.id
  }
}

resource deployPlanStorageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobServices
  name: 'plan'
  properties: {
    publicAccess: 'None'
    denyEncryptionScopeOverride: false
    defaultEncryptionScope: '$account-encryption-key'
  }
}

resource deployPlanStorageContainerStorageBlobDataContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(deployPlanStorageContainer.id, 'ado-principal')
  scope: deployPlanStorageContainer
  properties: {
    principalId: principalId
    roleDefinitionId: storageBlobDataContributorRoleDefinition.id
  }
}

resource deployPlanStorageContainerManagementPolicies 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = {
  name: 'default'
  parent: deployStateStorage
  properties: {
    policy: {
      rules: [
        {
          name: 'Delete Old Plans'
          enabled: true
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                delete: {
                  daysAfterModificationGreaterThan: 30
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
              prefixMatch: [
                '${deployPlanStorageContainer.name}/'
              ]
            }
          }
        }
      ]
    }
  }
}
