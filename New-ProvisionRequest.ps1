workflow New-ProvisionRequest
{
param(
[Parameter(Mandatory=$True)]
[bool]$production

)

if ($production -eq $true)
    {
    $location = Get-AutomationVariable -Name "ProdLocation"
    $domain = Get-AutomationVariable -Name "ProdDomain"
    $WebServerOSVersion = Get-AutomationVariable -Name "ProdWSOSVer"
    $AppTierOSVersion = Get-AutomationVariable -Name "ProdATOSVer"
    [int]$webinstances = 3
    [int]$appinstances = 3
    $vnetname = Get-AutomationVariable -Name "ProdVNETName"
    $subnetname = Get-AutomationVariable -Name "ProdSubnetName"
    $vnetrg = Get-AutomationVariable -Name "ProdVnetRG"
    $webserverStorageAccount = Get-AutomationVariable -Name "ProdStandardSA"
    $appserverStorageAccount = Get-AutomationVariable -Name "ProdStandardSA"
    $subscription = Get-AutomationVariable -Name "ProdSubscription"
    }
else{
    $location = Get-AutomationVariable -Name "DevLocation"
    $domain = Get-AutomationVariable -Name "DevDomain"
    $WebServerOSVersion = Get-AutomationVariable -Name "DevWSOSVer"
    $AppTierOSVersion = Get-AutomationVariable -Name "DevATOSVer"
    [int]$webinstances = 1
    [int]$appinstances = 1
    $vnetname = Get-AutomationVariable -Name "DevVNETName"
    $subnetname = Get-AutomationVariable -Name "DevSubnetName"
    $vnetrg = Get-AutomationVariable -Name "DevVnetRG"
    $webserverStorageAccount = Get-AutomationVariable -Name "DevStandardSA"
    $appserverStorageAccount = Get-AutomationVariable -Name "DevStandardSA"
    $subscription = Get-AutomationVariable -Name "DevSubscription"
    }


[string]$deploymentName = ("Deployment" + (Get-Date -Format Hmmss))
$webserverparams = @{
                     'DeploymentName'=$deploymentName;
                     'ResourceGroupName'="WebTier";
                     'VMNamePrefix'="WebDem0";
                     'DSCNodeConfigurationName'="WebTier.Webserver";
                     'DomaintojoinFQDN'=$domain;
                     'OSVersion'=$WebServerOSVersion;
                     'NumberOfVMInstances'=$webinstances;
                     'VirtualNetworkName'=$vnetname;
                     'SubnetName'=$subnetname;
                     'VnetResourceGroupName'=$vnetrg;
                     'StorageAccountName'=$webserverStorageAccount;
                     'SubscriptionName'=$subscription
                     'DeploymentLocation'=$location
                     } 

#Build Web Servers
$cred = Get-AutomationPSCredential -Name "AzureAutomation"
#Add-AzureAccount -Credential $cred 
#Get-AzureSubscription -SubscriptionName jorsmith-SCDemo | Select-AzureSubscription
Login-AzureRmAccount -Credential $cred -SubscriptionName jorsmith-scdemo -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47


Start-AzureRmAutomationRunbook -AutomationAccountName AZa-Demo -Name Deploy-AzureFullVM -Parameters $webserverparams -ResourceGroupName Services

[string]$deploymentName = ("Deployment" + (Get-Date -Format Hmmss))
$appserverparams = @{
                    'DeploymentName'=$deploymentName;
                    'ResourceGroupName'="AppTier";
                    'VMNamePrefix'="AppDem0";
                    'DSCNodeConfigurationName'="AppTier.AppServer";
                    'DomaintojoinFQDN'=$domain;
                    'OSVersion'=$AppTierOSVersion;
                    'NumberOfVMInstances'=$appinstances;
                    'VirtualNetworkName'=$vnetname;
                    'SubnetName'=$subnetname;
                    'VnetResourceGroupName'=$vnetrg;
                    'StorageAccountName'=$appserverStorageAccount;
                    'SubscriptionName'=$subscription;
                    'DeploymentLocation'=$location
                    }


Start-AzureRmAutomationRunbook -AutomationAccountName AZa-Demo -Name Deploy-AzureFullVM -Parameters $appserverparams -ResourceGroupName Services

}