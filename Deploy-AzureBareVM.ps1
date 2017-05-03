
param(
[Parameter(Mandatory=$True)]
$deploymentName,
[Parameter(Mandatory=$True)]
$deploymentLocation,
[Parameter(Mandatory=$True)]
$ResourceGroupName,
[Parameter(Mandatory=$True)]
$vmNamePrefix,
[Parameter(Mandatory=$True)]
[int]$numberofVMinstances,
[Parameter(ValueFromPipeline=$True)]
$OSVersion,
[Parameter(Mandatory=$True)]
$virtualNetworkName,
[Parameter(Mandatory=$True)]
$virtualNetworkRGName,
[Parameter(Mandatory=$True)]
$storageaccountname
)

$templateuri = "https://raw.githubusercontent.com/lorax79/AzureTemplates/master/avm-base-bare.json"
$apw = Get-AutomationVariable -Name "vmAdminPW" 

$paramhash = @{
              'adminUsername' = "LocalAdmin";
              'vmNamePrefix' = $vmNamePrefix;
              'numberOfInstances' = $numberofVMinstances;
              'virtualNetworkName' = $virtualNetworkName;
              'adminPassword' = "$($apw)";
              'imageSKU' = $OSVersion;
              'virtualNetworkResourceGroup' = $virtualNetworkRGName;
              'storageAccountName' = $storageaccountname
               }
               
$cred = Get-AutomationPSCredential -Name "AzureAutomation"
Login-AzureRmAccount -Credential $cred -SubscriptionId 95874f21-e6c8-4742-94f4-7698a4b50762 -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

#Validate Resource Group exists and create if not
$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ea 0
if (!($rg))
    {
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $deploymentLocation
    }

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -Mode Incremental -TemplateFile $templateuri -TemplateParameterObject $paramhash

