RG='azure-devops-track-jash'
az account set --subscription e5cfa658-369f-4218-b58e-cece3814d3f1
az group create -l eastus -n $RG
az deployment group create --resource-group $RG --template-file biceptemplate/main.bicep --parameters biceptemplate/parameters.bicepparam