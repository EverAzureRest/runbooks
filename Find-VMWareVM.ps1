params(
$user,
$vmName,
$vCenterServer
) 

if (!(get-pssnapin VmWare.PowerCLI))
    {Add-PSSnapin VmWare.PowerCLI}


$output = { ##Code to Find VM with User and VMName passed in##
            }

Write-Output $output