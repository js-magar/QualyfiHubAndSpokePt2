//All parameters defined in PARAMETERS file.
param location string
param name string
param GatewaySubnetName string
param AppgwSubnetName string
param AzureFirewallSubnetName string
param AzureBastionSubnetName string
param DefaultNSGName string
param firewallName string

param coreVnetName string
param devVnetName string
param hubVnetName string
param prodVnetName string

param devAppServicePlanName string
param devAppServiceName string
param prodAppServicePlanName string
param prodAppServiceName string
param logAnalyticsWorkspaceName string
param recoveryServiceVaultName string

param prodVnetAddressPrefix string
param devVnetAddressPrefix string
param coreVnetAddressPrefix string
param hubVnetAddressPrefix string
param prodVnetAddress string
param devVnetAddress string
param coreVnetAddress string
param hubVnetAddress string

//tags
param hubTag object
param coreTag object
param prodTag object
param devTag object
param coreServicesTag object


//RSV
module recoveryServiceVaults 'br:bicep/modules/recovery-services.vault:1.0.0' = {
  name:recoveryServiceVaultName
  params: {
    location:location
    tags:coreServicesTag
    publicNetworkAccess:'Disabled'
  }
}
//log analytics
module logAnalyticsWorkspace 'br/public:storage/log-analytics-workspace:1.0.1' = {
  name: 'logAnalyticsDeployment'
  params: {
    name: logAnalyticsWorkspaceName
    location:location
    tags:coreServicesTag

  }
}
//Virtual Networks
module coreVnet 'br/public:network/virtual-network:1.0.1' = {
  name: 'coreVNetDeployment'
  params: {
    name: coreVnetName
    addressPrefixes: [
      coreVnetAddress
    ]
  }
}
module hubVnet 'br/public:network/virtual-network:1.0.1' = {
  name: 'hubVNetDeployment'
  params: {
    name: hubVnetName
    addressPrefixes: [
      hubVnetAddress
    ]
  }
}
module devVnet 'br/public:network/virtual-network:1.0.1' = {
  name: 'devVNetDeployment'
  params: {
    name: devVnetName
    addressPrefixes: [
      devVnetAddress
    ]
  }
}
module prodVnet 'br/public:network/virtual-network:1.0.1' = {
  name: 'prodVNetDeployment'
  params: {
    name: prodVnetName
    addressPrefixes: [
      prodVnetAddress
    ]
  }
}
//DNS Zones
module appServicePrivateDnsZone 'br/public:network/private-dns-zone:1.0.1' = {
  name:'appServicePrivateDnsZone'
  params: {
    name: 'privatelink.azurewebsites.net'
    tags:coreServicesTag
    location:location
    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkId: coreVnet.outputs.resourceId
      }
      {
        name: 'link-dev'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkId: devVnet.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkId: hubVnet.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkId: prodVnet.outputs.resourceId
      }
    ]
  }
}
module sqlPrivateDnsZone 'br/public:network/private-dns-zone:1.0.1' = {
  name:'sqlPrivateDnsZone'
  params: {
    name: 'privatelink${environment().suffixes.sqlServerHostname}'
    tags:coreServicesTag
    location:location
    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkId: coreVnet.outputs.resourceId
      }
      {
        name: 'link-dev'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkId: devVnet.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkId: hubVnet.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkId: prodVnet.outputs.resourceId
      }
    ]
  }
}
module storageAccountPrivateDnsZone 'br/public:network/private-dns-zone:1.0.1' = {
  name:'storageAccountPrivateDnsZone'
  params: {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    tags:coreServicesTag
    location:location
    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkId: coreVnet.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkId: hubVnet.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkId: prodVnet.outputs.resourceId
      }
    ]
  }
}
module encryptKVPrivateDnsZone 'br/public:network/private-dns-zone:1.0.1' = {
  name:'encryptKVPrivateDnsZone'
  params: {
    name: 'privatelink${environment().suffixes.keyvaultDns}'
    tags:coreServicesTag
    location:location
  }
}



