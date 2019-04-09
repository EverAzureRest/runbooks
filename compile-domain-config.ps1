param(
        [Parameter(Mandatory)]
        [String]$domainFQDN,
        [Parameter(Mandatory)]
        [String]$AutomationAccountRG,
        [Parameter(Mandatory)]
        [String]$AutomationAccountName,
        [Parameter(Mandatory)]
        [String]$KeyVaultName
)

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

$dacred = New-Object System.Management.Automation.PSCredential((Get-AzureKeyVaultSecret -Name domainadmin -vaultname $KeyVaultName).SecretValueText,(Get-AzureKeyVaultSecret -Name domainadminpw -vaultname $KeyVaultName).SecretValueText)
$sfmpass = New-Object System.Management.Automation.PSCredential('',(Get-AzureKeyVaultSecret -Name domainadminpw -vaultname $KeyVaultName).SecretValueText)
$Params = @{
    domain = $domainFQDN
    dacred = $dacred
    sfmpass = $sfmpass
    }
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $True
        },
        @{
            NodeName = "PDCE"
            PSDscAllowDomainUser = $True
        }
    )
}



Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $AutomationAccountRG -AutomationAccountName $AutomationAccountName -ConfigurationName "Domain" -ConfigurationData $ConfigData -Parameters $Params