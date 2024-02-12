#Functions for easy repeat
function RandomiseString{
    param (
        [int]$allowedLength = 10,
        [string]$allowedText ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
    )
    $returnText = -Join($allowedText.tochararray() | Get-Random -Count $allowedLength | ForEach-Object {[char]$_})
    return $returnText
}
function SecureString{
    param ([string]$unsecuredString = "a")
    return (ConvertTo-SecureString $unsecuredString -AsPlainText -Force)
    
} 
#Parameters Decleration
$RG= "azure-hub-and-spoke-jash"
$SUB= "e5cfa658-369f-4218-b58e-cece3814d3f1"
$Location = "eastus"
$CoreTags = @{"Area"="CoreServices"}
$CoreSecretsKeyVaultName = "kv-secret-core-jash-001"


#Key Vault Properties|	
$VMAdminUsernameP = RandomiseString 
$VMAdminPasswordP = RandomiseString 16 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz&#$%?!1234567890"
$SQLAdminUsernameP = RandomiseString 
$SQLAdminPasswordP = RandomiseString 16 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz&#$%?!1234567890"
Write-Output "Virtual Machine Admin Username : $VMAdminUsernameP"
Write-Output "Virtual Machine Admin Password : $VMAdminPasswordP"
Write-Output "SQL Admin Password : $SQLAdminUsernameP"
Write-Output "SQL Admin Password : $SQLAdminPasswordP"
Write-Output "CoreSecretsKeyVaultName : $CoreSecretsKeyVaultName"

az login
az account set --subscription $SUB
az group create -l eastus -n $RG
$SPName= "sp-github-actions-landing-zone-jash"
$ScopeName= "/subscriptions/$SUB/resourceGroups/$RG"
az ad sp create-for-rbac --name $SPName --role owner --scopes $ScopeName --json-auth
#Deploy Keyvault
az keyvault create --name $CoreSecretsKeyVaultName --resource-group $RG --location $Location --enabled-for-template-deployment true --tags $CoreTags
#Set Secrets
az keyvault secret set --name 'VMAdminUsername' --vault-name $CoreSecretsKeyVaultName --value (SecureString $VMAdminUsernameP)
az keyvault secret set --name 'VMAdminPassword' --vault-name $CoreSecretsKeyVaultName --value (SecureString $VMAdminPasswordP)
az keyvault secret set --name 'SQLAdminUsername' --vault-name $CoreSecretsKeyVaultName --value (SecureString $SQLAdminUsernameP)
az keyvault secret set --name 'SQLAdminPassword' --vault-name $CoreSecretsKeyVaultName --value (SecureString $SQLAdminPasswordP)

#az deployment group create --resource-group $RG --template-file biceptemplate/main.bicep --parameters biceptemplate/parameters.bicepparam