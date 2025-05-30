targetScope='subscription'

type subscriptionName = 'dev' | 'uat' | 'prod' | 'training'

@description('Name of the subscripion to bootstrap')
param subName subscriptionName

@description('Id of the principal to grant access to the terraform storage account container')
param principalId string

resource deployRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'gha-test-sub-${subName}'
  location: deployment().location
}

module resources 'resources.bicep' = {
  name: 'gha-test-subscription-bootstrap'
  scope: deployRG
  params: {
    subName: subName
    principalId: principalId
  }
}
