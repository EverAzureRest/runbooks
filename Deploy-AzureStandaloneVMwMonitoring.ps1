
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
$storageaccountname,
[Parameter(Mandatory=$True)]
$subnetname
)

$templateuri = "https://github.com/lorax79/AzureTemplates/raw/master/avm-base-MMAonly.json"
$apw = Get-AutomationVariable -Name "vmAdminPW" 

$paramhash = @{
              'adminUsername' = "LocalAdmin";
              'vmNamePrefix' = $vmNamePrefix;
              'numberOfInstances' = $numberofVMinstances;
              'virtualNetworkName' = $virtualNetworkName;
              'workspaceid' = "55a750e9-a324-41b8-ae9f-31cd1efc5be2";
              'workspacekey' = "+zHnAbUCYjduvU2sjCOKRavppLHclExNemTZ0MfVxPr3z3xVp/zMeqOXWzB3Z4b7vhtP3cz/nQFqL10BNdfo8Q==";
              'adminPassword' = "$($apw)";
              'imageSKU' = $OSVersion;
              'virtualNetworkResourceGroup' = $virtualNetworkRGName;
              'storageAccountName' = $storageaccountname;
              'subnetname' = $subnetname
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

