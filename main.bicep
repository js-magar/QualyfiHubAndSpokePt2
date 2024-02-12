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

var RG = resourceGroup().name
var CoreSecVaultName='keyvaultname'
var RandString=substring(uniqueString(resourceGroup().id),0,5)
//Hub
var GatewaySubnetAddress = '${hubVnetAddressPrefix}.1.0/24'
var AppgwSubnetAddress = '${hubVnetAddressPrefix}.2.0/24'
var AzureFirewallSubnetAddress = '${hubVnetAddressPrefix}.3.0/24'
var AzureBastionSubnetAddress = '${hubVnetAddressPrefix}.4.0/24'
var AzureFirewallPrivateIP ='${hubVnetAddressPrefix}.3.4'
var bastionPIPName ='pip-bastion-hub-${location}-001'
var bastionName ='bastion-hub-${location}-001' 
var firewallPIPName = 'pip-firewall-hub-${location}-001'
var firewallPolicyName ='firewallPolicy-hub-${location}-001' 
var firewallRulesName ='firewallRules-hub-${location}-001'
var appGatewayPIPName = 'pip-appGateway-hub-${location}-001'
var appGatewayName = 'appGateway-hub-${location}-001'
var appgw_id = resourceId('Microsoft.Network/applicationGateways','appGateway-hub-${location}-001')
//Core
var vmSubetName = 'VMSubnet'
var kvSubetName = 'KVSubnet'
var vmSubnetAddress = '${coreVnetAddressPrefix}.1.0/24'
var kvSubnetAddress = '${coreVnetAddressPrefix}.2.0/24'
var vmName ='vm-core-${location}-001'
var vmSize = 'Standard_D2S_v3'
var vmNICName = 'nic-core-${location}-001'
var vmNICIP = '10.20.1.20'
var vmComputerName = 'coreComputer'
var CoreEncryptKeyVaultName = 'kv-encrypt-core-jash'
//Spoke
var appServiceSubnetName ='AppSubnet'
var SQLServerSubnetName ='SqlSubnet'
var SASubnetName ='StSubnet'
var prodOrDev = [0,1] //[prod,dev]
var adminUsername='username'
var adminPassword='ExamplePassword2002?'
var SQLServerSku = 'Basic'
var devSQLServerName = 'sql-dev-${location}-001-${RandString}'
var prodSQLServerName = 'sql-prod-${location}-001-${RandString}'
var devSQLDatabaseName = 'sqldb-dev-${location}-001-${RandString}'
var prodSQLDatabaseName = 'sqldb-prod-${location}-001-${RandString}'
var storageAccountName = 'stprod001${RandString}'
var appServiceRepoURL = 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'
var storageAccountPrivateEndpointName ='private-endpoint-${storageAccountName}'

//KV
//resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
//  name: CoreSecVaultName
//}
//RSV
/*
module recoveryServiceVaults './ResourceModules/modules/recovery-services/vault/main.bicep' ={
//'br:bicep/modules/recovery-services.vault:1.0.0' = { //CARML
  name:recoveryServiceVaultName
  params: {
    managedIdentities: {
      systemAssigned: true
    }
    name:recoveryServiceVaultName
    location:location
    tags:coreServicesTag
    publicNetworkAccess:'Disabled'
  }
}
*/
//log analytics
module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.3.1' = { //MODULES
  name: 'logAnalyticsDeployment'
  params: {
    name: logAnalyticsWorkspaceName
    location:location
    tags:coreServicesTag
    useResourcePermissions: true
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
module applicationInsights 'br/public:avm/res/insights/component:0.1.2' = [for spokeType in prodOrDev: {
  name:'${(spokeType==0) ? 'prod' : 'dev'}AppInsightsDeployment'
  params:{
    name:'${(spokeType==0) ? 'prod' : 'dev'}-${location}-aSInsights'
    location:location
    tags:(spokeType==0) ? prodTag : devTag
    workspaceResourceId:logAnalyticsWorkspace.outputs.resourceId 
    kind:'web'
    applicationType: 'web'
  }
}]
module appServicePlan 'br/public:avm/res/web/serverfarm:0.1.0' = [for spokeType in prodOrDev: {
  name: '${(spokeType==0) ? 'prod' : 'dev'}AppServicePlanDeployment'
  params:{
    name: (spokeType==0) ? prodAppServicePlanName : devAppServicePlanName
    location:location
    reserved:true
    tags:(spokeType==0) ? prodTag : devTag
    kind: 'Linux'
    sku:{
      name: 'B1'
      tier : 'Basic'
    }
  }
}]
module appService 'br/public:avm/res/web/site:0.2.0' =  [for spokeType in prodOrDev: {
  name: '${(spokeType==0) ? 'prod' : 'dev'}AppServiceDeployment'
  params:{
    name:(spokeType==0) ? prodAppServiceName : devAppServiceName
    kind:'app'
    serverFarmResourceId: appServicePlan[spokeType].outputs.resourceId
    appInsightResourceId:applicationInsights[spokeType].outputs.resourceId
    diagnosticSettings:[
      {
        //eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        //eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId 
      }
    ]
    siteConfig:{
      linuxFxVersion:'DOTNETCORE|7.0'
      appSettings:[
        {
          name:'APPINSIGHTS_INSTRUMENTATIONKEY'
          value:applicationInsights[spokeType].outputs.instrumentationKey
        }
        /*
        {
          name:'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value:applicationInsights[spokeType].properties.ConnectionString
        }*/
        {
          name:'ApplicationInsightsAgent_EXTENSION_VERSION'
          value:'~3'
        }
        {
          name:'XDT_MicrosoftApplicationInsights_Mode'
          value:'default'
        }
      ]
      alwaysOn:true
    }
    privateEndpoints: [
      {
        name:(spokeType==0) ? 'private-endpoint-${prodAppServiceName}' : 'private-endpoint-${devAppServiceName}'
        privateDnsZoneResourceIds: [
          appServicePrivateDnsZone.outputs.resourceId
        ]
        subnetResourceId: (spokeType==0) ? prodVnet.outputs.subnetResourceIds[0] : devVnet.outputs.subnetResourceIds[0]
        customNetworkInterfaceName : (spokeType==0) ? 'pip-${prodAppServiceName}' : 'pip-${devAppServiceName}'
      }
    ]
  }
}]
resource codeAppService 'Microsoft.Web/sites/sourcecontrols@2022-09-01' =[for spokeType in prodOrDev: {
  name:(spokeType==0) ? '${prodAppServiceName}/web' : '${devAppServiceName}/web'
  properties:{
    repoUrl:appServiceRepoURL
    isManualIntegration:true
    branch:'master'
  }
  dependsOn:[
    appService
  ]
}] //NEEDS TO BE CHANGE
//SQL
module sqlServer 'br/public:avm/res/sql/server:0.1.5' = [for spokeType in prodOrDev: {
  name:'${(spokeType==0) ? 'prod' : 'dev'}SQLServer'
  params:{
    name: (spokeType==0) ? prodSQLServerName : devSQLServerName
    administratorLogin:adminUsername
    administratorLoginPassword:adminPassword
    location:location
    databases: [
      {
        skuName:SQLServerSku
        skuTier:SQLServerSku
        name: (spokeType==0) ? prodSQLDatabaseName : devSQLDatabaseName
        maxSizeBytes:2147483648 //Must be exactly 2GB
      }
    ]
    privateEndpoints: [
      {
        name:(spokeType==0) ? 'private-endpoint-${prodSQLServerName}' : 'private-endpoint-${devSQLServerName}'
        privateDnsZoneResourceIds: [
          sqlPrivateDnsZone.outputs.resourceId
        ]
        service: 'sqlServer'
        subnetResourceId: (spokeType==0) ? prodVnet.outputs.subnetResourceIds[1] : devVnet.outputs.subnetResourceIds[1]
        customNetworkInterfaceName : (spokeType==0) ? 'pip-${prodSQLServerName}' : 'pip-${devSQLServerName}'
      }
    ]
  }
}]
//SA
module storageAccount 'br/public:avm/res/storage/storage-account:0.5.0' = {
  name: 'storageAccountDeployment'
  params: {
    name: storageAccountName
    skuName:'Standard_LRS'
    kind:'StorageV2'
    location:location
    privateEndpoints: [
      {
        name:storageAccountPrivateEndpointName
        privateDnsZoneResourceIds: [
          storageAccountPrivateDnsZone.outputs.resourceId
        ]
        service: 'blob'
        subnetResourceId: prodVnet.outputs.subnetResourceIds[2]
        customNetworkInterfaceName :'pip-${storageAccountName}'
      }
    ]
  }
}
// Hub
//Bastion Code
module bastion 'br/public:avm/res/network/bastion-host:0.1.1' = {
  name:'bastionDeployment'
  params:{
    name: bastionName
    vNetId:hubVnet.outputs.resourceId
    location:location
    tags:hubTag
    publicIPAddressObject: {
      allocationMethod: 'Static'
      name: bastionPIPName
      skuName: 'Standard'
      tags: hubTag
    }
    skuName: 'Standard'
  }
}
//Firewall Code
module azureFirewall './ResourceModules/modules/network/azure-firewall/main.bicep' = {
  name: 'firewallDeployment'
  params: {
    // Required parameters
    name: firewallName
    // Non-required parameters
    location: location
    hubIPAddresses:{
      privateIPAddress: AzureFirewallPrivateIP
    }
    publicIPAddressObject: {
      name: firewallPIPName
      publicIPAllocationMethod: 'Static'
      skuName: 'Standard'
    }
    tags:hubTag
    vNetId: hubVnet.outputs.resourceId
    firewallPolicyId:firewallPolicy.outputs.resourceId
    diagnosticSettings: [
      {
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId  
      }
    ]
  }
}
module firewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.0' = {
  name:'firewallPolicyDeployment'
  params:{
    name: firewallPolicyName
    tags:hubTag
    location: location
    ruleCollectionGroups: [
      {
        name: firewallRulesName
        priority: 200
        ruleCollections: [
          {
            action: {
              type: 'Allow'
            }
            name: 'allowAllRule'
            priority: 1100
            ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
            rules: [
              {
                name:'Rule1'
                ruleType:'NetworkRule'
                ipProtocols:['Any']
                sourceAddresses:['*']
                destinationAddresses:['*']
                destinationPorts:['*']
              }
            ]
          }
        ]
      }
    ]
  }
}
//AppGateway
module applicationGateway  './ResourceModules/modules/network/application-gateway/main.bicep' = {
  name:'appGatewayDeployment'
  params: {
    name: appGatewayName
    tags:hubTag
    location: location
    backendAddressPools:[
      {
        name:'backendAddressPool'
        properties:{
          backendAddresses:[{
            fqdn:'${prodAppServiceName}.azurewebsites.net'
          }]
        }
      }
    ]
    backendHttpSettingsCollection:[
      {
        name:'backendHttpPort80'
        properties:{
          port:80
          protocol:'Http'
          pickHostNameFromBackendAddress:true
        }
      }
    ]
    frontendIPConfigurations:[
      {
        name:'appGatewayFrontendConfig'
        properties:{
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress:{
            id:appGatewayPIP.outputs.resourceId
          }
        }
      }
    ]
    frontendPorts:[
      {
        name:'frontendHttpPort80'
        properties:{
          port:80
        }
      }
    ]
    gatewayIPConfigurations:[
      {
        name:'appGatewayIPConfig'
        properties:{
          subnet:{
            id:hubVnet.outputs.subnetResourceIds[0]
          }
        }
      }
    ]
    httpListeners:[
      {
          name:'appGWHttpListener'
          properties:{
            frontendIPConfiguration:{
              id:'${appgw_id}/frontendIPConfigurations/appGatewayFrontendConfig'
            }
            frontendPort:{
              id:'${appgw_id}/frontendPorts/frontendHttpPort80'
            }
            protocol:'Http'
          }
      }
    ]
    requestRoutingRules:[
      {
        name:'appGWRoutingRule'
        properties:{
          ruleType:'Basic'
          priority:110
          httpListener:{
            id:'${appgw_id}/httpListeners/appGWHttpListener'
          }
          backendAddressPool:{
            id:'${appgw_id}/backendAddressPools/backendAddressPool'
          }
          backendHttpSettings:{
            id:'${appgw_id}/backendHttpSettingsCollection/backendHttpPort80'
          }

        }
      }
    ]
    sku:'Standard_v2'
    autoscaleMinCapacity:1
    autoscaleMaxCapacity:5
  }
}
module appGatewayPIP 'br/public:avm/res/network/public-ip-address:0.2.2' = {
  name:'appGatewayPIPDeployment'
  params:{
    name: appGatewayPIPName
    location:location
    skuName: 'Standard'
    tags:hubTag
    publicIPAllocationMethod:'Static'
  }
}
//VPN GATEWAY
//ADD
//
//

//core
module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.2.1' = {
  name:'VMDeployment'
  params:{
    adminUsername: adminUsername
    adminPassword: adminPassword
    computerName: vmComputerName
    encryptionAtHost:false
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    name: vmName
    location:location
    backupPolicyName: 'DefaultPolicy'
    backupVaultName: recoveryServiceVaultName
    backupVaultResourceGroup: RG
    nicConfigurations: [
      {
        deleteOption: 'Delete'
        ipConfigurations: [
          {
            name: 'ipconfig'
            privateIPAllocationMethod: 'Static' 
            privateIPAddress: vmNICIP
            subnetResourceId: coreVnet.outputs.subnetResourceIds[0]
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    osDisk: {
      name: 'name'
      caching: 'ReadWrite'
      diskSizeGB: '128'
      createOption: 'FromImage'
      managedDisk:{
        storageAccountType:'Standard_LRS'
      }
    }
    osType: 'Windows'
    vmSize: vmSize
    extensionAzureDiskEncryptionConfig: {
      enabled: true
      settings: {
        EncryptionOperation: 'EnableEncryption'
        KeyVaultURL: encryptionKeyVault.outputs.uri
        KeyVaultResourceId: encryptionKeyVault.outputs.resourceId
        VolumeType: 'All'
        ResizeOSDisk: false
      }
    }
    extensionAntiMalwareConfig: {
      enabled: true
      settings: {
        AntimalwareEnabled: 'true'
        RealtimeProtectionEnabled: 'true'
      }
      tags:coreTag
    }
    extensionDependencyAgentConfig: {
      enabled: true
      tags:coreTag
    }
    extensionMonitoringAgentConfig: {
      enabled: true
      monitoringWorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId 
      tags:coreTag
    }
  }
}
/*
resource windowsVMGuestConfigExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: windowsVM
  name: 'AzurePolicyforWindows'
  tags:coreTag
  location: RGLocation
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}
//maybe need data collection rule
*/
//Key Vault
module encryptionKeyVault 'br/public:avm/res/key-vault/vault:0.3.4' = {
  name:'encryptionKeyVaultDeployment'
  params:{
    name:CoreEncryptKeyVaultName
    tags:coreTag
    location:location
    enableRbacAuthorization: false
    enableVaultForDeployment:true
    enableVaultForDiskEncryption:true
    enableVaultForTemplateDeployment:true
    networkAcls:{
      defaultAction:'Allow'
      bypass:'AzureServices'
    }
    sku:'standard'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          encryptKVPrivateDnsZone.outputs.resourceId
        ]
        service: 'vault'
        subnetResourceId:  coreVnet.outputs.subnetResourceIds[1]
        tags:coreTag
      }
    ]
  }
}

//Hub Gateway
module hubGateway 'br/public:avm/res/network/virtual-network-gateway:0.1.0' = {
  name: 'hubGatewayDeployment'
  params: {
    gatewayType: 'Vpn'
    name:'hubgateway-hub-${location}-001'
    skuName: 'VpnGw2'
    vNetResourceId: hubVnet.outputs.resourceId
    location: location
    gatewayPipName: 'pip-hubgateway-hub-${location}-001'
    domainNameLabel:[
      'hubgateway'
    ]
  }
}
