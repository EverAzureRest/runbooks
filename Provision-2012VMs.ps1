
param(
[Parameter(Mandatory=$True)]
$deploymentName,
[Parameter(Mandatory=$True)]
$ResourceGroupName,
#[Parameter(Mandatory=$True)]
#$AdminUsername,
[Parameter(Mandatory=$True)]
$vmNamePrefix,
[Parameter(Mandatory=$True)]
[int]$numberofVMinstances,
[Parameter(Mandatory=$True)]
$DSCNodeConfigurationName
#[Parameter(Mandatory=$True)]
#$DomainFQDNToJoin
)

$templateuri = "https://raw.githubusercontent.com/lorax79/AzureTemplates/master/azuredeploy2012r2.json"


[string]$timestamp = (get-date -Format "MM/dd/yyyy H:mm:ss tt")
$apw = Get-AutomationVariable -Name "vmAdminPW" 
$adminPassword = ConvertTo-SecureString $apw -AsPlainText -Force
$dpw = Get-AutomationVariable -Name "domainjoinpw"
$DomainJoinPassword = ConvertTo-SecureString $dpw -AsPlainText -Force

$paramhash = @{
              'adminUsername' = "LocalAdmin";
              'vmNamePrefix' = $vmNamePrefix;
              'workspaceid' = "55a750e9-a324-41b8-ae9f-31cd1efc5be2";
              'workspacekey' = "+zHnAbUCYjduvU2sjCOKRavppLHclExNemTZ0MfVxPr3z3xVp/zMeqOXWzB3Z4b7vhtP3cz/nQFqL10BNdfo8Q==";
              'numberOfInstances' = $numberofVMinstances;
              'nodeConfigurationName' = $DSCNodeConfigurationName;
              'registrationURL' = "https://eus2-agentservice-prod-1.azure-automation.net/accounts/d506ffba-1bf5-409d-a317-751a2c68f0d4";
              'registrationkey' = "pjA/ESlbjlH5OHv2IU110Vv6YfPhdYsLQKae7rg1oFb1U37cUtasnyUnhVotTEWKzt1eH9pmRKnXbpByqwf4CQ==";
              'adminPassword' = "$($apw)";
              'domainUsername' = "Join";
              'domainToJoin' = "powerhell.org";
              'domainPassword' = "$($dpw)"
              'timestamp' = $timestamp
               }
               
$cred = Get-AutomationPSCredential -Name "AzureAutomation"
Login-AzureRmAccount -Credential $cred -SubscriptionId 3c2b4a2b-3a92-4714-91b9-c6945f8857c1 -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47


New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -Mode Incremental -TemplateFile $templateuri -TemplateParameterObject $paramhash

