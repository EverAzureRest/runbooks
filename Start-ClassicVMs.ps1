workflow Start-ClassicVMs
{

$runcredental = Get-AutomationPSCredential -Name "AzureAutomation"

add-azureaccount -Credential $runcredental

Select-AzureSubscription -SubscriptionName jorsmith-contosodemo

Get-AzureVM | Start-AzureVM

}