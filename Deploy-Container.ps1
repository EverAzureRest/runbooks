workflow Deploy-Container
{


$storagecred = New-Object -typename pscredential -ArgumentList @{"Username" = "$parameter"; "Password" = "$parameter"}

Copy-Item \\$parameter.file.core.windows.net\sclab\NikeApp.zip -Credential $storagecred -Destination \\cont0-0\NikeApp.zip


$deploy = {

Unblock-File c:\NikeApp.zip
Invoke-Command {docker.exe load c:\NikeApp.zip}
Invoke-Command {docker.exe run --name NikeApp -p 80:80 -it windowscoreiiswithchanges cmd}

          }

Invoke-Command -ComputerName -credential (Get-AutomationPSCredential -Name "DomainAutomation") -ScriptBlock $deploy


}