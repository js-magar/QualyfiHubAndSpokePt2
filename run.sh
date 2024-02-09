export MSYS_NO_PATHCONV=1
RG='azure-hub-and-spoke-jash'
SUB='e5cfa658-369f-4218-b58e-cece3814d3f1'
az account set --subscription $SUB
az group create -l eastus -n $RG
az deployment group create --resource-group $RG --template-file biceptemplate/main.bicep --parameters biceptemplate/parameters.bicepparam

SPName='sp-github-actions-landing-zone-jash'
ScopeName="/subscriptions/$SUB/resourceGroups/$RG"
az ad sp create-for-rbac --name $SPName --role owner --scopes $ScopeName --json-auth
