$TBLatest = ( Invoke-WebRequest  "https://product-details.mozilla.org/1.0/thunderbird_versions.json" | ConvertFrom-Json ).LATEST_THUNDERBIRD_VERSION
$temp = choco list thunderbird --all
$ver = $temp[1] -replace "[^0-9\.]",''

$repoVersion = $temp -replace "[^0-9]", ''
$latestVersion = $TBLatest -replace "[^0-9]", ''

$arrayrepoV = $repoVersion[1].ToCharArray()
$arraylatestV = $latestVersion.ToCharArray()

if($arrayrepoV.length -gt $arraylatestV.length){
   $max = $arrayrepoV.length
}
else{
   $max = $arraylatestV.length
}

for($i=0; $i -lt $max; $i++){
    if($arraylatestV[$i] -gt $arrayrepoV[$i]){
	    write-host "Update Available from $($temp[1]) to $TBLatest"
		break
	}
	elseif($arraylatestV[$i] -lt $arrayrepoV[$i]){
	    write-host "No available update"
		break
	}	
	else{	    
	    continue
	}
}

$line = Get-Content thunderbird.nuspec  | Select-String "<version>" | Select-Object -ExpandProperty Line
$content = Get-Content thunderbird.nuspec
$content | ForEach-Object {$_ -replace $line,"<version>$TBLatest</version>"} | Set-Content thunderbird.nuspec

$contentps1 = Get-Content -Path "./tools/chocolateyinstall.ps1"
$contentps1[12] = "`$fileLocation= Join-Path `$toolsDir `'thunderbird $TBLatest.exe`'"
Set-Content -Path "./tools/chocolateyinstall.ps1" -Value $contentps1

$url = "https://download.mozilla.org/?product=thunderbird-$TBLatest-SSL&os=win&lang=el"
$fileName = "thunderbird $TBLatest.exe"
Invoke-WebRequest -Uri $url -OutFile "./tools/$fileName"
Remove-Item "thunderbird.$ver.nupkg"
choco pack
choco push --source "http://localhost/chocolatey" -k="chocolateyrocks" --force