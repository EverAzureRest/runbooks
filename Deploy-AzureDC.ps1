
param(
[Parameter(Mandatory=$True)]
$ResourceGroupName,
[Parameter(Mandatory=$True)]
$vmNamePrefix,
[Parameter(Mandatory=$True)]
$DCRole,
[Parameter(Mandatory=$True)]
[int]$numberofVMinstances,
[Parameter(Mandatory=$True)]
$OSVersion,
[Parameter(Mandatory=$True)]
$virtualNetworkName,
[Parameter(Mandatory=$True)]
$subnetname,
[Parameter(Mandatory=$True)]
$vnetResourceGroupName,
[Parameter(Mandatory=$True)]
$subscriptionName,
[Parameter(Mandatory=$True)]
$deploymentlocation,
[Parameter(Mandatory=$True)]
$keyVaultName
)


$templateuri = "https://raw.githubusercontent.com/EverAzureRest/AzureTemplates/master/avm-base-DC.json"

$mmawsid = (Get-AzureKeyVaultSecret -VaultName $keyVaultName -n "workspaceid").SecretValueText
$mmswskey = (Get-AzureKeyVaultSecret -VaultName $keyVaultName -n "workspacekey").SecretValueText
$dscurl = "https://eus2-agentservice-prod-1.azure-automation.net/accounts/d506ffba-1bf5-409d-a317-751a2c68f0d4"
$dsckey = (Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name "dscregistrationkey").SecretValueText
$apw = (Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name "domainAdminpw").SecretValueText
$domainadmin = (Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name "domainAdmin").SecretValueText
$DscNodeConfigurationName = Domain
[string]$timestamp = (get-date -Format "MM/dd/yyyy H:mm:ss tt")
$deploymentName = 'DCdeployment' + (get-date -Format "yyyy.dd.MM.H.mm.ss")

<# 
if ($DCRole -eq "BDC")
    {
    $dpw = Get-AutomationVariable -Name "domainjoinpw"
    }
#>

$paramhash = @{
              adminUsername = $domainAdmin
              vmNamePrefix = $vmNamePrefix
              workspaceid = $mmawsid
              workspacekey = $mmswskey
              numberOfInstances = $numberofVMinstances
              nodeConfigurationName = $DSCNodeConfigurationName
              registrationURL = $dscurl
              registrationkey = $dsckey
              adminPassword = $apw
              imageSKU = $OSVersion
              timestamp = $timestamp
              subnetname = $subnetname
              virtualNetworkName = $virtualNetworkName
              virtualNetworkResourceGroup = $vnetResourceGroupName
               }
               
$cred = Get-AutomationPSCredential -Name "AzureAutomation"
Login-AzureRmAccount -Credential $cred -SubscriptionName $subscriptionName -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ea 0
if (!($rg))
    {
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $deploymentlocation
    }

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -Mode Incremental -TemplateFile $templateuri -TemplateParameterObject $paramhash

