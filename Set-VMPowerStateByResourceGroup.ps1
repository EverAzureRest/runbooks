param(
$subscriptionName,
$resourcegroupName,
[bool]$start,
[bool]$stop
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

Set-AzureRmContext -SubscriptionName $subscriptionName



if ($stop -eq $true){
   Get-AzureRmVM -ResourceGroupName $resourcegroupName | Stop-AzureRmVM -ResourceGroupName $resourcegroupName -Force
}
elseif ($start -eq $true){
    Get-AzureRmVM -ResourceGroupName $resourcegroupName | Start-AzureRmVM -ResourceGroupName $resourcegroupName
} 