
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
$DSCNodeConfigurationName,
[Parameter(ValueFromPipeline=$True)]
[Validateset('2008-R2-SP1', '2012-Datacenter', '2012-R2-Datacenter', 'Windows-Server-Technical-Preview')]
$OSVersion
)


$templateuri = "https://raw.githubusercontent.com/lorax79/AzureTemplates/master/avm-base-standalone.json"

[string]$timestamp = (get-date -Format "MM/dd/yyyy H:mm:ss tt")
$apw = Get-AutomationVariable -Name "vmAdminPW" 

$paramhash = @{
              'adminUsername' = "LocalAdmin";
              'vmNamePrefix' = $vmNamePrefix;
              'workspaceid' = "55a750e9-a324-41b8-ae9f-31cd1efc5be2";
              'workspacekey' = "+zHnAbUCYjduvU2sjCOKRavppLHclExNemTZ0MfVxPr3z3xVp/zMeqOXWzB3Z4b7vhtP3cz/nQFqL10BNdfo8Q==";
              'numberOfInstances' = $numberofVMinstances;
              'nodeConfigurationName' = $DSCNodeConfigurationName;
              'registrationURL' = "https://eus2-agentservice-prod-1.azure-automation.net/accounts/61fcc721-4107-4150-ad71-e4c1f53b7559";
              'registrationkey' = "kO87VoTWo1VKfUWYCQVTnAJ93ONMv7EKlB1xNWSpf/+JP/VzmKCn4NXJniFcGdjh3rfJVETynoKyvcuF9O6HeQ==";
              'adminPassword' = "$($apw)";
              'imageSKU' = $OSVersion;
              'timestamp' = $timestamp
               }
               
$cred = Get-AutomationPSCredential -Name "AzureAutomation"
Login-AzureRmAccount -Credential $cred -SubscriptionId 95874f21-e6c8-4742-94f4-7698a4b50762 -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

#Validate Resource Group exists and create if not
$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ea 0
if (!($rg))
    {
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location "EastUS2"
    }

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -Mode Incremental -TemplateFile $templateuri -TemplateParameterObject $paramhash

