param(
[object]$webhookdata
)

if ($webhookdata -ne $null)

    {

    $params = $webhookdata.RequestBody | ConvertFrom-Json
    $action = $params.action
    $region = $params.region

    }

else 
    { 

    $ErrorMessage = "The Parameters block from the webhook is null"
    throw $ErrorMessage

    }


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

Import-Module -Name AzureRM.KeyVault
$vpnPass = (Get-AzureKeyVaultSecret -VaultName (Get-AutomationVariable -Name keyvaultName) -Name vpnpass).SecretValueText
$dnsLabel = Get-AutomationVariable -Name "DNSLabel"
$resourceGroupName = "opensocks"
$containerName = "opensocks"
$containerImage = "oddrationale/docker-shadowsocks"
$command = "/usr/local/bin/ssserver -k $($vpnpass)"


if ($action -icontains "start")
    {
     try 
        {
        New-AzureRmResourceGroup -Name $resourceGroupName -Location $region
        New-AzureRmContainerGroup -ResourceGroupName $resourceGroupName -Location $region -Name $containerName -Image $containerImage -IpAddressType Public -Command $command -Port 8388 -DnsNameLabel $dnsLabel
        }
    catch 
        {
        Write-Error -Message $_.Exception
        throw $_.Exception
        }
    }
elseif ($action -icontains "stop")
    {
    Remove-AzureRmContainerGroup -ResourceGroupName $resourceGroupName -Name $containerName -Confirm:$false
    Remove-AzureRmResourceGroup -Name $resourceGroupName -Confirm:$false -Force
    }