﻿
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
$deploymentlocation
)


$templateuri = "https://raw.githubusercontent.com/lorax79/AzureTemplates/master/avm-full-SQL-standalone.json"

[string]$timestamp = (get-date -Format "MM/dd/yyyy H:mm:ss tt")
$apw = Get-AutomationVariable -Name "vmAdminPW" 


$paramhash = @{
              'adminUsername' = "LocalAdmin";
              'vmNamePrefix' = $vmNamePrefix;
              'numberOfInstances' = $numberofVMinstances;
              'nodeConfigurationName' = $DSCNodeConfigurationName;
              'registrationURL' = "https://eus2-agentservice-prod-1.azure-automation.net/accounts/61fcc721-4107-4150-ad71-e4c1f53b7559";
              'registrationkey' = "kO87VoTWo1VKfUWYCQVTnAJ93ONMv7EKlB1xNWSpf/+JP/VzmKCn4NXJniFcGdjh3rfJVETynoKyvcuF9O6HeQ==";
              'adminPassword' = "$($apw)";
              'imageSKU' = $OSVersion;
              'timestamp' = $timestamp;
              'subnetname' = $subnetname;
              'virtualNetworkName' = $virtualNetworkName;
              'virtualNetworkResourceGroup' = $vnetResourceGroupName
               }
               
$cred = Get-AutomationPSCredential -Name "AzureAutomation"
Login-AzureRmAccount -Credential $cred -SubscriptionName $subscriptionName

$rg = Get-AzureRmResourceGroup -Name $ResourceGroupName -ea 0
if (!($rg))
    {
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $deploymentlocation
    }

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -Mode Incremental -TemplateFile $templateuri -TemplateParameterObject $paramhash

 