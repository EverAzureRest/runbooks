workflow Deploy-Container
{


$storagecred = New-Object -typename pscredential -ArgumentList @{"Username" = "sclabapkj6n2tobyrs"; "Password" = "f4SAV7mCffOPT3F/Po3475IV/rTRaO389Kr2RZMkuS9s2Uzizkh6dxSMUVuyPvp408jYfoNZVYvuysnxwhQSjQ=="}

Copy-Item \\sclabapkj6n2tobyrs.file.core.windows.net\sclab\NikeApp.zip -Credential $storagecred -Destination \\cont0-0\NikeApp.zip


$deploy = {

Unblock-File c:\NikeApp.zip
Invoke-Command {docker.exe load c:\NikeApp.zip}
Invoke-Command {docker.exe run --name NikeApp -p 80:80 -it windowscoreiiswithchanges cmd}

          }

Invoke-Command -ComputerName -credential (Get-AutomationPSCredential -Name "DomainAutomation") -ScriptBlock $deploy


}