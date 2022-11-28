function remoteapps{

[CmdletBinding()]

param

(

[Parameter(Mandatory=$False)]
[ValidateNotNullOrEmpty()]
$appName,

[Parameter(Mandatory=$False)]
[ValidateNotNullOrEmpty()]
$appPath
)
$path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppAllowList\Applications"
$port = "" #ex. 3386
$fulladdress = "" #ex. machine.lab.test.gr
$workspaceid = "" #ex. machine.lab.test.gr
$iconPath = "" #an accessible path which contains the needed icons

set-location -path "C:/"
$a = New-Object -ComObject Scripting.FileSystemObject 
$f = $a.GetFolder($appPath)
$shortPath = $f.ShortPath
#$shortPath = ./shortname $appPath

set-location -path "C:\Program Files (x86)\NirSoft\IconsExtract"
./iconsext.exe /save "$appPath" "C:\remoteAppsIcons\$appName\" -icons | Out-Null
$contents = Get-ChildItem -Path "C:\remoteAppsIcons\$appName\" -Force -Recurse -File | Select-Object -First 1
$icoName = $contents.name
$icoName

set-location -path $path
New-Item -Name $appName
New-ItemProperty -Path "$path\$appName" -Name "CommandLineSetting" -Value 0 -PropertyType "DWord"
New-ItemProperty -Path "$path\$appName" -Name "ShowInTSWA" -Value 0 -PropertyType "DWord"
New-ItemProperty -Path "$path\$appName" -Name "Name" -Value "$appName" -PropertyType "String"
New-ItemProperty -Path "$path\$appName" -Name "Path" -Value "$appPath" -PropertyType "String"
New-ItemProperty -Path "$path\$appName" -Name "RequiredCommandLine" -Value "" -PropertyType "String"
New-ItemProperty -Path "$path\$appName" -Name "SecurityDescriptor" -Value "" -PropertyType "String"
New-ItemProperty -Path "$path\$appName" -Name "ShortPath" -Value $shortPath -PropertyType "String"
New-ItemProperty -Path "$path\$appName" -Name "IconIndex" -Value 0 -PropertyType "DWord"
New-ItemProperty -Path "$path\$appName" -Name "IconPath" -Value "C:\remoteAppsIcons\$appName\$icoName" -PropertyType "String"

New-RDRemoteApp -CollectionName "RemoteApps" -DisplayName "$appName" -FilePath "$appPath"

New-Item "c:\remoteapps\$appName.rdp"
Set-Content "c:\remoteapps\$appName.rdp" "redirectclipboard:i:1
redirectposdevices:i:0
redirectprinters:i:1
redirectcomports:i:0
redirectsmartcards:i:1
devicestoredirect:s:*
drivestoredirect:s:*
redirectdrives:i:1
session bpp:i:32
prompt for credentials on client:i:1
span monitors:i:1
use multimon:i:1
remoteapplicationmode:i:1
server port:i:$port
allow font smoothing:i:1
promptcredentialonce:i:0
videoplaybackmode:i:1
audiocapturemode:i:1
gatewayusagemethod:i:0
gatewayprofileusagemethod:i:1
gatewaycredentialssource:i:0
full address:s:$fulladdress
alternate shell:s:||$appName
remoteapplicationprogram:s:||$appName
remoteapplicationname:s:$appName
remoteapplicationcmdline:s:
remoteapplicationicon:s:$iconPath\$appName\$icoName
workspace id:s:$workspaceid
use redirection server name:i:1
loadbalanceinfo:s:tsv://MS Terminal Services Plugin.1.RemoteApps"

$WshShell=New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("c:\remoteApps\$appName(Remote Desktop App).lnk")
$Shortcut.TargetPath = "\\accessibleIP\remoteapps\$appName.rdp"
$Shortcut.IconLocation = "\\accessibleIP\remoteappsicons\$appName\$icoName"
$Shortcut.Save()
}