@description('Required. Name of the source control.')
param name string

@description('Required. kind for source control.')
param kind string

@description('Required. Name of the parent app service')
param appServiceName string 

@description('Required. ')
param branch string 

@description('Required. ')
param repoUrl string

@description('Optional. ')
param deploymentRollbackEnabled bool = false

@description('Optional. ')
param gitHubActionConfiguration object = {}

@description('Optional. ')
param isGitHubAction bool = false

@description('Optional. ')
param isManualIntegration bool = false

@description('Optional. ')
param isMercurial bool = false


resource app 'Microsoft.Web/sites@2022-09-01' existing =  {
  name: appServiceName
}

resource symbolicname 'Microsoft.Web/sites/sourcecontrols@2022-09-01' = {
  name: name
  kind: kind
  parent: app
  properties: {
    branch: branch
    deploymentRollbackEnabled: deploymentRollbackEnabled
    gitHubActionConfiguration: gitHubActionConfiguration 
    isGitHubAction: isGitHubAction
    isManualIntegration: isManualIntegration
    isMercurial: isMercurial
    repoUrl: repoUrl
  }
}
