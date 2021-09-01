$net = New-Object -ComObject WScript.Network
$net.MapNetworkDrive("L:", "\\test.test.gr\Common", $false, "user", "password")

$suffix = ""

$cname = $env:computername
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$LogPath = (Get-Item -Path "L:\tpm-logs" -ErrorAction SilentlyContinue).FullName
if($LogPath -eq $null) { New-Item -Path "L:\" -Name "tpm-logs" -ItemType "directory" }
$LogPath = (Get-Item -Path "L:\tpm-logs\$cname" -ErrorAction SilentlyContinue).FullName
if($LogPath -eq $null) { New-Item -Path "L:\tpm-logs" -Name $cname -ItemType "directory" }
$fileSuffix = $suffix
if(($fileSuffix -ne $null) -and ($fileSuffix -ne "")) { $fileSuffix = "-$fileSuffix" }
$LogPath = "L:\tpm-logs\$cname\$Date$fileSuffix.log"

$biosPassword="password"
$biosPassword2="password"
$FolderToCreate = "C:/"
#if (!(Test-Path $FolderToCreate -PathType Container)) {
#    New-Item -ItemType Directory -Force -Path $FolderToCreate
#}
$getManufacturer = (Get-WmiObject Win32_Computersystem).manufacturer
If($getManufacturer -like "*dell*"){
	#check if dell command configure is installed
    $installed=test-path -path "${env:ProgramFiles(x86)}\Dell\Command Configure\X86_64"
    if(-Not $installed)
    {
        $job=Start-Job -Name comconf -ScriptBlock {choco install DELL_BCU -y --force}
        Wait-Job -Name comconf
        $result=Receive-Job -Job $job 
		$result | Out-File $LogPath -Append
        Add-Content -Path "C:/setBios-Logs/logs.txt" -value $result
    }	
	#create logs
    cd "${env:ProgramFiles(x86)}\Dell\Command Configure\X86_64"    
    if (!(Test-Path "logs")){
        New-Item -ItemType Directory "logs"
    }
    New-Item "logs/log.txt"  
	#set bios password
	#./cctk --setuppwd="$biosPassword"
	#enable tpm
	$log=./cctk --tpm=on --valsetuppwd="$biosPassword"
	$log | Out-File $LogPath -Append
	if($log -match "The setup password provided is incorrect."){
		$biosPassword = $biosPassword2
		$log2 = ./cctk --tpm=on --valsetuppwd="$biosPassword"
		$log2 | Out-File $LogPath -Append
	}	
	$command = "$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist `'user`', `'password`';New-PsDrive -Name `'L`' -Root `'\\test.test.gr\Common`' -PSProvider FileSystem  -Credential $credential;cd `'${env:ProgramFiles(x86)}\Dell\Command Configure\X86_64`'; ./cctk.exe --tpmactivation=activate --valsetuppwd=`'$biosPassword`' --logfile `'$LogPath`'; Unregister-ScheduledTask -TaskName `'ExecuteCommand`' -Confirm:$False; Restart-Computer -Force"
	#Restart-Computer -Force
	$Trigger= New-ScheduledTaskTrigger -AtStartUp
	$User= "NT AUTHORITY\SYSTEM"
	$Action= New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-command `"$command`""
	Register-ScheduledTask -TaskName "ExecuteCommand" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest -Force
	#./cctk --tpmactivation=activate --valsetuppwd="$biosPassword" --logfile "${env:ProgramFiles(x86)}\Dell\Command Configure\X86_64\logs\log.txt"	
	Restart-Computer -Force
}
