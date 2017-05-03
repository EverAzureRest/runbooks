workflow Start-Lab
{
param(
[Parameter(Mandatory=$True)]
[bool]$start,
[bool]$envbase,
[bool]$envlab
)

if(
$start -eq $true
)
    {
    $runbookname = "Start-ARMVMs"
    }
elseif(
$start -eq $false
)
    {
    $runbookname = "Stop-ARMVMs"
    }


if(
$envbase -eq $true
)
    {
    $resourcegroups = "domaintier","catier"
    }
elseif(
$envlab -eq $true
)
    {
    $resourcegroups = "domaintier","catier","datatier","scom","scor","rhel"
    }

foreach ($resourcegroup in $resourcegroups)
    {


$params = @{
            'resourcegroup'=$resourcegroup;
            'subscriptionname'="jorsmith-labsub1"
           }

$cred = Get-AutomationPSCredential -Name "AzureAutomation"
Login-AzureRmAccount -Credential $cred -SubscriptionName jorsmith-scdemo -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47
Start-AzureRmAutomationRunbook -AutomationAccountName AZa-Demo -Name $runbookname -Parameters $params -ResourceGroupName Services
    
    }

}