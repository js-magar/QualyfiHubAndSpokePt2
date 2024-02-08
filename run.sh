export MSYS_NO_PATHCONV=1
RG='azure-devops-track-jash'
az account set --subscription e5cfa658-369f-4218-b58e-cece3814d3f1
az group create -l eastus -n $RG
az deployment group create --resource-group $RG --template-file biceptemplate/main.bicep --parameters biceptemplate/parameters.bicepparam

#SPName='sp-github-actions-landing-zone-jash'
#az ad sp create-for-rbac --name $SPName --role owner --scopes /subscriptions/e5cfa658-369f-4218-b58e-cece3814d3f1/resourceGroups/azure-devops-track-jash --sdk-auth
