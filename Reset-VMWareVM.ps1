workflow Reset-VMWareVM
{
param(
[Parameter(Mandatory=$True)]
$vmName,
[Parameter(Mandatory=$True)]
$ExecutionUser
)

$executioncredential = Get-AutomationPSCredential -Name $ExecutionUser
[array]$vCenterServers = Get-AutomationVariable -Name VcenterServers

foreach -parallel ($instance in $vCenterServers)
{

$params = @{
            'user' = $ExecutionUser;
            'vmName' = $vmName
            'vCenterServer' = $instance
            }

$vminfo = Start-AzureRmAutomationRunbook -Name Find-VMWareVM -Parameters $params -ResourceGroupName RGofAutomationAccount -RunOn HybridWorkerGroup -Wait -MaxWaitSeconds
}

if ($vminfo -ne $null)
    {
    $vmparams = @{
                 'vmname'=$vminfo.Name
                 'vCenterServer'=$vminfo.VcenterServer
                 'ExecutionAccount'=$executioncredential
                 }
    $statusreset = Start-AzureRmAutomationRunbook -Name Reset-VMWareVM -Parameters $vmparams -ResourceGroupName RGofAutomationAccount -RunOn HybridWorkerGroup
    }
else
    {
    write-error -Exception "VM $vmName could not be found in the list of vCenter servers - please check the name and try again" -MergeErrorToOutput 
    }



Write-Output $statusreset

}