
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
[string]$RHELOSVersion,
[Parameter(Mandatory=$True)]
$virtualNetworkName,
[Parameter(Mandatory=$True)]
$subnetname,
[Parameter(Mandatory=$True)]
$vnetResourceGroupName,
[Parameter(Mandatory=$True)]
$storageAccountName,
[Parameter(Mandatory=$True)]
$subscriptionName,
[Parameter(Mandatory=$True)]
$deploymentlocation
)


$templateuri = "https://raw.githubusercontent.com/lorax79/AzureTemplates/master/avm-base-RHEL.json"

$apw = Get-AutomationVariable -Name "vmAdminPW" 


$paramhash = @{
              'adminUsername' = "LocalAdmin";
              'vmNamePrefix' = $vmNamePrefix;
              'workspaceid' = "55a750e9-a324-41b8-ae9f-31cd1efc5be2";
              'workspacekey' = "+zHnAbUCYjduvU2sjCOKRavppLHclExNemTZ0MfVxPr3z3xVp/zMeqOXWzB3Z4b7vhtP3cz/nQFqL10BNdfo8Q==";
              'numberOfInstances' = $numberofVMinstances;
              'adminPassword' = "$($apw)";
              'rhelOSVersion' = $RHELOSVersion;
              'subnetname' = $subnetname;
              'virtualNetworkName' = $virtualNetworkName;
              'virtualNetworkResourceGroup' = $vnetResourceGroupName;
              'storageAccountName' = $storageAccountName
               }
               
$cred = Get-AutomationPSCredential -Name "AzureAutomation"
Login-AzureRmAccount -Credential $cred -SubscriptionName $subscriptionName -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ea 0
if (!($rg))
    {
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $deploymentlocation
    }

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -Mode Incremental -TemplateFile $templateuri -TemplateParameterObject $paramhash

 