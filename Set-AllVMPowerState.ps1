param(
$subscriptionName,
[bool]$start,
[bool]$stop
)

$credential = Get-AutomationPSCredential -Name "AzureAutomation"

Login-AzureRmAccount -Credential $credential

Get-AzureRmSubscription -SubscriptionName $subscriptionName | Select-AzureRmSubscription

$resourcegroups = get-AzureRmResourceGroup

if ($stop -eq $true){
$resourcegroups.resourcegroupname | foreach $_ { 
Get-AzureRmResource -ResourceGroupName $_ -ResourceType Microsoft.Compute/virtualMachines | Stop-AzureRmVM $_ -Force}
}
elseif ($start -eq $true){
$resourcegroups.resourcegroupname | foreach $_ { 
Get-AzureRmResource -ResourceGroupName $_ -ResourceType Microsoft.Compute/virtualMachines | Start-AzureRmVM $_ }
} 