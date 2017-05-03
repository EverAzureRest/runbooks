
param(
[Parameter(Mandatory=$True)]
$deploymentName,
[Parameter(Mandatory=$True)]
$ResourceGroupName,
[Parameter(Mandatory=$True)]
$vmNamePrefix,
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
$subscriptionName
)

$templateuri = "https://raw.githubusercontent.com/lorax79/AzureTemplates/master/avm-base-DC.json"
$apw = Get-AutomationVariable -Name "vmAdminPW" 
if (!($virtualNetworkName))
    {$virtualNetworkName = "ProdVnet"}

$paramhash = @{
              'adminUsername' = "LocalAdmin";
              'vmNamePrefix' = $vmNamePrefix;
              'numberOfInstances' = $numberofVMinstances;
              'virtualNetworkName' = $virtualNetworkName;
              'adminPassword' = "$($apw)";
              'imageSKU' = $OSVersion;
              'virtualNetworkResourceGroup' = $vnetResourceGroupName;
              'storageAccountName' = $storageAccountName;
              'subnetName' = $subnetname
               }
               
$cred = Get-AutomationPSCredential -Name "AzureAutomation"
Login-AzureRmAccount -Credential $cred -SubscriptionName $subscriptionName -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

#Validate Resource Group exists and create if not
$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ea 0
if (!($rg))
    {
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location "EastUS2"
    }

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -Mode Incremental -TemplateFile $templateuri -TemplateParameterObject $paramhash

