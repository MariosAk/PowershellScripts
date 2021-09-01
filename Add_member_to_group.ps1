$groupName="groupname"
$names=get-Content "users.txt"
foreach($name in $names){
    try{
    Add-ADGroupMember -Identity $groupName -Members $name
    Write-Output "User $name added to $groupName`n"
    }catch{
        Write-Output $_.exception.Message
    }
}