# QualyfiHubAndSpoke using AVM
Welcome to my project.
In this project I have created a hub and spoke landing zone with multiple spokes.

In this project I have used the AVM (Azure Verified Modules), Bicep Registry Modules and CARML (Common Azure Resource Modules Library).

To use this template please run the following command to connect to Azure with an authenticated account:
```
az login
```
Once connected please run the following code to deploy the secrets key vault, this will create default secrets and create a key vault for the VM and SQL DB to use. This will also provide you with a service principle, if one has not been made already:
```
.\deploy.ps1
```
This code uses github actions, which is ran every time a new version is pushed. Workflows can also be triggered via the Actions tab.


Success Criteria:
- [x] 1. RDP (via the Bastion) to the Windows Server VM securely via the internet
- [x] 2 Browse the internet from the Windows Server VM via the hub firewall - to test this, in the VM use the DOS command:
      ```
      tracert 8.8.8.8
      ```
- [x] 3. Check the SQL connection (port 1433 ) is open from the VM to the Prod SQL Server private endpoint ip address - use Powershell:
      ```
      Test-NetConnection -port "1433" -computer "10.31.2.4"
      ```
- [x] 4. Browse to the Prod App (on HTTP port 80) via the internet via the Application Gateway public IP - it should load the 'Hello World' website
- [x] 5. Check the Firewall logs in the Log Analytics Workspace for SQL 1 433 traffic - in the Firewall logs use the kql command:
      ```
      AzureDiagnostics | where msg_s contains "1433"
      ```
- [] 6. Check the VM insights for VM performance activity - in the VM resource in the portal, open the Insights blade and open the Performance tab to see the metrics
- [ ] 7. Check the Log Analytics Workspace for the Windows Events Logs - use KQL Query
      ```
      Event
      ```
- [x] 8. Check the App Insights for the Prod Web App activity - in the App Insights resource in the portal, open the Live Metrics blade to see live metrics to the website
- [] 9. Run the initial backup of the VM to the Recovery Services Vault - in the Recovery Services Vault in the portal, open the Backup Items blade and open the Virtual Machine items
- [] 10. Delete and restore the VM
- [ ] 11. Restore the VM as a clone with a new name in Azure and Windows (optional)
- [] 12. Resolve the private DNS names from the VM to the private endpoints internal IP addresses - in the VM use the DOS command nslookup to lookup the private DNS
