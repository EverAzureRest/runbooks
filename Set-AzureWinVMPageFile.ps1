workflow Set-AzureWinVMPageFile
{
param (
$vmName,
[Parameter(Mandatory)]
$resourceGroup,
[Parameter(Mandatory)]
$location
)

$automationResourceGroup = "EUS2Services" #Make Global Var
$automationAccountName = "LabSubAutomation" #Make Global Var

$params = @{
'vmName'=$vmName;
'resourceGroup'=$resourceGroup;
'scriptName'="CustomScriptExtension"
'fileUri'="https://raw.githubusercontent.com/lorax79/Scripts/master/Set-AzureVMSwap.ps1";
'scriptFile'="Set-AzureVMSwap.ps1";
'location'=$location
}

#Login as ServicePrincipal
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

Start-AzureRmAutomationRunbook -AutomationAccountName $automationAccountName -Name Execute-CustomScript -ResourceGroupName $automationResourceGroup -Parameters $params


}