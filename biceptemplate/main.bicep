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


//rsv

//log analytics

//vnets
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
