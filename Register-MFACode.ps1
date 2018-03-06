param([Parameter(Mandatory=$true)][String]$ProfileName,[Parameter(Mandatory=$true)][String]$MFAkey)

$configFilePath = "$($env:HOMEDRIVE)$($env:HOMEPATH)\saved-MFAs.dat"

if(-not (Test-Path -Path $configFilePath -PathType Leaf)){
    $xmlBody=
@'
<?xml version="1.0" encoding="utf-8"?>
<configs>
    <cred name="template">
        <MFAKey>blabllblalblalblalblalba</MFAKey>
    </cred>
</configs>
'@
    $xml = [xml]$xmlBody
}else{
    $xml = [xml](Get-Content $configFilePath)
}

$existingNode = $xml.SelectNodes("//cred[@name='$ProfileName']")
if(@($existingNode).Count -eq 0){
    $newNode = $xml.configs.ChildNodes[0].Clone()
    $newNode.name = $ProfileName
    $newNode.MFAKey = [String](ConvertFrom-SecureString (ConvertTo-SecureString -AsPlainText -Force -String $MFAkey))
    $xml.configs.AppendChild($newNode) | Out-Null
      
}elseif(@($existingNode).Count -eq 1){
    $newNode = $existingNode[0]
    $newNode.MFAKey = [String](ConvertFrom-SecureString (ConvertTo-SecureString -AsPlainText -Force -String $MFAkey))
}else{
    Write-Error "Plusieurs noeuds existent avec le nom $ProfileName"
    exit
}
$warningMessage=@"
The profile "$ProfileName" has been set and the key securely saved.
PLEASE ensure that your Powershell history file do not contains the key, as it can be red by any computer admin.
This file is usally at "$($env:HOMEDRIVE)$($env:HOMEPATH)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt"
"@
Write-Host -ForegroundColor Yellow $warningMessage
$xml.Save($configFilePath)