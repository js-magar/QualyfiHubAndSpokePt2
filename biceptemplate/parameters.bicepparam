using 'main.bicep'

param location = 'eastus' // This value must be provided.
//param location  = resourceGroup().location
param name = 'jash' // This value is optional. Bicep will use default value if not provided.
var RandString = 'jash'

//Subnet names
param GatewaySubnetName ='GatewaySubnet'
param AppgwSubnetName ='AppgwSubnet'
param AzureFirewallSubnetName ='AzureFirewallSubnet'
param AzureBastionSubnetName ='AzureBastionSubnet'

//Vnet names
param coreVnetName = 'vnet-core-${location}-001'
param devVnetName = 'vnet-dev-${location}-001'
param hubVnetName = 'vnet-hub-${location}-001'
param prodVnetName = 'vnet-prod-${location}-001'

param DefaultNSGName ='defaultNSG'
param firewallName = 'firewall-hub-${location}-001'
param devAppServicePlanName = 'asp-dev-${location}-001-${RandString}'
param devAppServiceName = 'as-dev-${location}-001-${RandString}'
param prodAppServicePlanName = 'asp-prod-${location}-001-${RandString}'
param prodAppServiceName = 'as-prod-${location}-001-${RandString}'
param logAnalyticsWorkspaceName = 'log-core-${location}-001-${RandString}'
param recoveryServiceVaultName = 'rsv-core-${location}-001'

//Prefixes
param prodVnetAddressPrefix = '10.31'
param devVnetAddressPrefix = '10.30'
param coreVnetAddressPrefix = '10.20'
param hubVnetAddressPrefix = '10.10'
//Addresses
param coreVnetAddress='${coreVnetAddressPrefix}.0.0/16'
param devVnetAddress='${devVnetAddressPrefix}.0.0/16'
param prodVnetAddress='${prodVnetAddressPrefix}.0.0/16'
param hubVnetAddress='${hubVnetAddressPrefix}.0.0/16'
//tags
param hubTag ={ Dept:'Hub', Owner:'HubOwner'}
param coreTag ={ Dept:'Core', Owner:'CoreOwner'}
param prodTag ={ Dept:'Prod', Owner:'ProdOwner'}
param devTag ={ Dept:'Dev', Owner:'DevOwner'}
param coreServicesTag ={ Dept:'CoreServices', Owner:'CoreServicesOwner'}
