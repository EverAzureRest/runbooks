workflow Stop-ClassicVMs
{
$runcredental = Get-AutomationPSCredential -Name "AzureAutomation"


Add-AzureAccount -Credential $runcredental

Select-AzureRmSubscription -SubscriptionName jorsmith-contosodemo

Get-AzureVM | Stop-AzureVM -Force

}