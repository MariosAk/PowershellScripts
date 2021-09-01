$pc=Get-Content "pc.txt"
$win32UserFilter = "NOT SID = 'S-x-x-x' AND NOT SID = 'S-x-x-x' AND NOT SID = 'S-x-x-x'"
foreach($pcname in $pc){   
	if (Test-Connection -ComputerName $pcname -Quiet -Count 1)
    {        
    $lastUser = Get-WmiObject -Class Win32_UserProfile -ComputerName $pcname -Filter $win32UserFilter -ErrorAction Stop | Sort-Object -Property @{Expression = {$_.ConvertToDateTime($_.LastUseTime)}; Descending = $True} | Select-Object -First 1
    $array=$lastUser.LocalPath.split('\')
    $name=$array[$array.Length-1]
    $name
	Add-Content -Path "pc-user.txt" -Value "$pcname $name`r`n"
	}
	else
	{
	Add-Content -Path "pc-user.txt" -Value "$pcname Cannot connect to computer $pcname `r`n"
    continue    
	}
}
