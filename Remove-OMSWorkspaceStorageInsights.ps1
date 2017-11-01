param(
[object]$WebhookData
)

if ($WebhookData -ne $null) {

    $params = $WebhookData.RequestBody | ConvertFrom-JSON

    $subscriptionName = $params.subscriptionName
    $WorkspaceName = $params.WorkspaceName
    $StorageAccountName = $params.storageAccountName

    Write-Output $subscriptionName
    Write-Output $WorkspaceName
    Write-Output $StorageAccountName

}
else {
    Write-Output "Error, there was no HTTP Payload Data in the Request - exiting"
    exit
}

#Add Service Principal Login
$connectionName = "AzureRunAsConnection"

try

{

    # Get the connection "AzureRunAsConnection "

    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         



    "Logging in to Azure..."

    Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
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

try {
    Set-AzureRmContext -SubscriptionName $subscriptionName
}

catch {
    if ($subscriptionName -eq $null) {
        $ErrorMessage = "Parameter for the Subscription Name is null. Check your parameters"
        Write-Error -Message $ErrorMessage
        throw $ErrorMessage
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}



try {
    $workspace = (Get-AzureRmOperationalInsightsWorkspace).Where({$_.Name -eq $WorkspaceName})    
}

catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
    }

if ($workspace -ne $null -and $StorageAccountName -ne $null)
    {
    Remove-AzureRmOperationalInsightsStorageInsight -ResourceGroupName $workspace.ResourceGroupName -WorkspaceName $workspace.Name -Name $StorageAccountName -Force
    }
else 
    {
    write-error -Message "The OMS Workspace $WorkspaceName, or the Storage Account $StorageAccountName could not be found - Please make sure the Workspace Name is correct and you are targeting the correct subscription"
    throw $_.Exception
    }