[cmdletbinding()] 
param(
$vmName,
$resourceGroup,
$scriptName,
$fileUri,
$scriptFile,
$location
)

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

Set-AzureRmVMCustomScriptExtension -ResourceGroupName $resourceGroup -VMName $vmName -Name $scriptName -FileUri $fileUri -Run $scriptFile -Location $location 