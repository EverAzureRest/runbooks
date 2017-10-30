param(
$WorkspaceName,
$StorageAccountName,
$subscriptionName)

#Add Service Principal Login
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

Set-AzureRmContext -Subscription $subscriptionName

$workspace = (Get-AzureRmOperationalInsightsWorkspace).Where({$_.Name -eq $WorkspaceName})

if ($workspace -ne $null)
    {
    Remove-AzureRmOperationalInsightsStorageInsight -ResourceGroupName $workspace.ResourceGroupName -WorkspaceName $workspace.Name -Name $StorageAccountName -Force
    }
else 
    {
    write-error -Message "The OMS Workspace $($WorkspaceName) could not be found - Please make sure the Workspace Name is correct and you are targeting the correct subscription"
    throw $_.Exception
    } 