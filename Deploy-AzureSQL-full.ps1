
param(
[Parameter(Mandatory=$True)]
$deploymentName,
[Parameter(Mandatory=$True)]
$ResourceGroupName,
[Parameter(Mandatory=$True)]
$vmNamePrefix,
[Parameter(Mandatory=$True)]
$DscNodeConfigurationName,
[Parameter(Mandatory=$True)]
$DomainToJoinFQDN,
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
$storageAccountName,
[Parameter(Mandatory=$True)]
$premiumStorageAccount,
[Parameter(Mandatory=$True)]
$subscriptionName,
[Parameter(Mandatory=$True)]
$deploymentlocation
)


$templateuri = "https://raw.githubusercontent.com/lorax79/AzureTemplates/master/avm-full-SQL.json"

[string]$timestamp = (get-date -Format "MM/dd/yyyy H:mm:ss tt")
$apw = Get-AutomationVariable -Name "vmAdminPW" 
$regkey = Get-AutomationVariable -Name "dscregistrationkey"
$mmawsid = Get-AutomationVariable -Name "mmawsid"
$mmswskey = Get-AutomationVariable -Name "mmawskey"
if ($DomainToJoinFQDN -eq "lab.contoso.com")
    {
    $dpw = Get-AutomationVariable -Name "domainjoinpw"
    }
elseif ($DomainToJoinFQDN -eq "powerhell.org")
    {
    $dpw = Get-AutomationVariable -Name "phdomainjoinpw"
    }

$paramhash = @{
              'adminUsername' = "LocalAdmin";
              'vmNamePrefix' = $vmNamePrefix;
              'workspaceid' = "$($mmawsid)";
              'workspacekey' = "$($mmswskey)";
              'numberOfInstances' = $numberofVMinstances;
              'nodeConfigurationName' = $DSCNodeConfigurationName;
              'registrationURL' = "https://eus2-agentservice-prod-1.azure-automation.net/accounts/61fcc721-4107-4150-ad71-e4c1f53b7559";
              'registrationkey' = "$($regkey)";
              'adminPassword' = "$($apw)";
              'domainUsername' = "domainjoin";
              'domainToJoin' = $DomainToJoinFQDN;
              'domainPassword' = "$($dpw)";
              'imageSKU' = $OSVersion;
              'timestamp' = $timestamp;
              'subnetname' = $subnetname;
              'virtualNetworkName' = $virtualNetworkName;
              'virtualNetworkResourceGroup' = $vnetResourceGroupName;
              'storageAccountName' = $storageAccountName;
              'premiumStorageAccountName' = $premiumStorageAccount
               }
               
$cred = Get-AutomationPSCredential -Name "AzureAutomation"
Login-AzureRmAccount -Credential $cred -SubscriptionName $subscriptionName -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ea 0
if (!($rg))
    {
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $deploymentlocation
    }

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -Mode Incremental -TemplateFile $templateuri -TemplateParameterObject $paramhash

 