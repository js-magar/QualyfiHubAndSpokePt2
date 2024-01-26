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

var CoreSecVaultName='keyvaultname'
var RandString='jash'
//Hub
var GatewaySubnetAddress = '${hubVnetAddressPrefix}.1.0/24'
var AppgwSubnetAddress = '${hubVnetAddressPrefix}.2.0/24'
var AzureFirewallSubnetAddress = '${hubVnetAddressPrefix}.3.0/24'
var AzureBastionSubnetAddress = '${hubVnetAddressPrefix}.4.0/24'
var AzureFirewallPrivateIP ='${hubVnetAddressPrefix}.3.4'
//Core
var vmSubetName = 'VMSubnet'
var kvSubetName = 'KVSubnet'
var vmSubnetAddress = '${coreVnetAddressPrefix}.1.0/24'
var kvSubnetAddress = '${coreVnetAddressPrefix}.2.0/24'
//Spoke
var appServiceSubnetName ='AppSubnet'
var SQLServerSubnetName ='SqlSubnet'
var SASubnetName ='StSubnet'
var prodOrDev = ['prod','dev']

//KV
//resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
//  name: CoreSecVaultName
//}
//RSV
/*
module recoveryServiceVaults 'br:bicep/modules/recovery-services.vault:1.0.0' = { //CARML
  name:recoveryServiceVaultName
  params: {
    location:location
    tags:coreServicesTag
    publicNetworkAccess:'Disabled'
  }
}
*/
//log analytics
module logAnalyticsWorkspace 'br/public:storage/log-analytics-workspace:1.0.1' = { //MODULES
  name: 'logAnalyticsDeployment'
  params: {
    name: logAnalyticsWorkspaceName
    location:location
    tags:coreServicesTag

  }
}
//NSG
module defaultNSG 'br/public:avm/res/network/network-security-group:0.1.2' = {
  name: DefaultNSGName
  params: {
    name: DefaultNSGName
    location:location
    tags:coreServicesTag
  }
}
//Virtual Networks
module hubVnet 'br/public:avm/res/network/virtual-network:0.1.1' = {
  name: 'hubVNetDeployment'
  params: {
    name: hubVnetName
    addressPrefixes: [
      hubVnetAddress
    ]
    subnets: [
      {
        name: GatewaySubnetName
        addressPrefix: GatewaySubnetAddress
      }
      {
        name: AppgwSubnetName
        addressPrefix: AppgwSubnetAddress
      }
      {
        name: AzureFirewallSubnetName
        addressPrefix: AzureFirewallSubnetAddress
      }
      {
        name: AzureBastionSubnetName
        addressPrefix: AzureBastionSubnetAddress
      }
    ]
  }
}
module coreVnet 'br/public:avm/res/network/virtual-network:0.1.1' = {
  name: 'coreVNetDeployment'
  params: {
    name: coreVnetName
    addressPrefixes: [
      coreVnetAddress
    ]
    peerings:[
      {
        allowForwardedTraffic: true
        allowGatewayTransit: true
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'core-to-hub'
        remoteVirtualNetworkId: hubVnet.outputs.resourceId
        //useRemoteGateways: false
      }
    ]
    subnets: [
      {
        name: vmSubetName 
        addressPrefix: vmSubnetAddress
        networkSecurityGroup:{  id: defaultNSG.outputs.resourceId }
        //routeTable:{id:routeTable.outputs.resourceId}
      }
      {
        name: kvSubetName
        addressPrefix: kvSubnetAddress
        networkSecurityGroup:{  id: defaultNSG.outputs.resourceId }
        //routeTable:{id:routeTable.outputs.resourceId}
      }
    ]
  }
}
module devVnet 'br/public:avm/res/network/virtual-network:0.1.1' = {
  name: 'devVNetDeployment'
  params: {
    name: devVnetName
    addressPrefixes: [
      devVnetAddress
    ]
    peerings:[
      {
        allowForwardedTraffic: true
        allowGatewayTransit: true
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'dev-to-hub'
        remoteVirtualNetworkId: hubVnet.outputs.resourceId
        //useRemoteGateways: false
      }
    ]
    subnets: [
      {
        name: appServiceSubnetName
        addressPrefix: '${devVnetAddressPrefix}.1.0/24'
        networkSecurityGroup:{  id: defaultNSG.outputs.resourceId }
        //routeTable:{id:routeTable.outputs.resourceId}
      }
      {
        name: SQLServerSubnetName
        addressPrefix: '${devVnetAddressPrefix}.2.0/24'
        networkSecurityGroup:{  id: defaultNSG.outputs.resourceId }
        //routeTable:{id:routeTable.outputs.resourceId}
      }
    ]
  }
}
module prodVnet 'br/public:avm/res/network/virtual-network:0.1.1' = {
  name: 'prodVNetDeployment'
  params: {
    name: prodVnetName
    addressPrefixes: [
      prodVnetAddress
    ]
    peerings:[
      {
        allowForwardedTraffic: true
        allowGatewayTransit: true
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'prod-to-hub'
        remoteVirtualNetworkId: hubVnet.outputs.resourceId
        //useRemoteGateways: false
      }
    ]
    subnets: [
      {
        name: appServiceSubnetName
        addressPrefix: '${prodVnetAddressPrefix}.1.0/24'
        networkSecurityGroup:{  id: defaultNSG.outputs.resourceId }
        //routeTable:{id:routeTable.outputs.resourceId}
      }
      {
        name: SQLServerSubnetName
        addressPrefix: '${prodVnetAddressPrefix}.2.0/24'
        networkSecurityGroup:{  id: defaultNSG.outputs.resourceId }
        //routeTable:{id:routeTable.outputs.resourceId}
      }
      {
        name: SASubnetName
        addressPrefix: '${prodVnetAddressPrefix}.3.0/24'
        networkSecurityGroup:{  id: defaultNSG.outputs.resourceId }
        //routeTable:{id:routeTable.outputs.resourceId}
      }
    ]
  }
}
//DNS Zones
module appServicePrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name:'appServicePrivateDnsZone'
  params: {
    name: 'privatelink.azurewebsites.net'
    tags:coreServicesTag
    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: coreVnet.outputs.resourceId
      }
      {
        name: 'link-dev'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: devVnet.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: hubVnet.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: prodVnet.outputs.resourceId
      }
    ]
  }
}
module sqlPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name:'sqlPrivateDnsZone'
  params: {
    name: 'privatelink${environment().suffixes.sqlServerHostname}'
    tags:coreServicesTag
    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: coreVnet.outputs.resourceId
      }
      {
        name: 'link-dev'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: devVnet.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: hubVnet.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: prodVnet.outputs.resourceId
      }
    ]
  }
}
module storageAccountPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name:'storageAccountPrivateDnsZone'
  params: {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    tags:coreServicesTag
    virtualNetworkLinks: [
      {
        name: 'link-core'
        location: 'global'
        tags:coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: coreVnet.outputs.resourceId
      }
      {
        name: 'link-hub'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: hubVnet.outputs.resourceId
      }
      {
        name: 'link-prod'
        location: 'global'
        tags: coreServicesTag
        registrationEnabled: false
        virtualNetworkResourceId: prodVnet.outputs.resourceId
      }
    ]
  }
}

module encryptKVPrivateDnsZone 'br/public:avm/res/network/private-dns-zone:0.2.3' = {
  name:'encryptKVPrivateDnsZone'
  params: {
    name: 'privatelink${environment().suffixes.keyvaultDns}'
    tags:coreServicesTag
  }
}
//Route Table
module routeTable 'br/public:avm/res/network/route-table:0.2.1' = {
  name:'routeTable'
  params:{
    name: 'routetable-${location}-001'
    location: location
    tags:hubTag
    routes: [
      {
        name: 'defaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType:'VirtualAppliance'
          nextHopIpAddress: AzureFirewallPrivateIP
        }
      }
      {
        name: 'core1Route'
        properties: {
          addressPrefix: coreVnetAddress
          nextHopType:'VirtualAppliance'
          nextHopIpAddress: AzureFirewallPrivateIP
        }
      }
      {
        name: 'dev1Route'
        properties: {
          addressPrefix: devVnetAddress
          nextHopType:'VirtualAppliance'
          nextHopIpAddress: AzureFirewallPrivateIP
        }
      }
      {
        name: 'prod1Route'
        properties: {
          addressPrefix: prodVnetAddress
          nextHopType:'VirtualAppliance'
          nextHopIpAddress: AzureFirewallPrivateIP
        }
      }
    ]
  }
}

//Spokes
//condition ? valueIfTrue : valueIfFalse
module appServicePlan 'br/public:avm/res/web/serverfarm:0.1.0' = [for spokeType in prodOrDev: {
  name: '${spokeType}AppServiceDeployment'
  params:{
    name: (spokeType=='prod') ? prodAppServicePlanName : devAppServicePlanName
    location:location
    reserved:true
    tags:(spokeType=='prod') ? prodTag : devTag
    kind: 'Linux'
    sku:{
      name: 'B1'
      tier : 'Basic'
    }
  }
}]
