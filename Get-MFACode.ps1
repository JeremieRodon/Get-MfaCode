param(
[Parameter(ParameterSetName='addCred',Mandatory=$true,Position=1)][String]$ProfileName,
[Parameter(ParameterSetName='listCred',Mandatory=$true)][switch]$ListProfile
)


$configFilePath = "$($env:HOMEDRIVE)$($env:HOMEPATH)\saved-MFAs.dat"
$mfaGeneratorScriptPath = "$($env:HOMEDRIVE)$($env:HOMEPATH)\TOTP.ps1"

if(-not (Test-Path -Path $configFilePath -PathType Leaf)){
    Write-Error "Could not find the config file at : $configFilePath"
    exit 1
}
if(-not (Test-Path -Path $mfaGeneratorScriptPath -PathType Leaf)){
    Write-Error "Could not find TOTP script at : $mfaGeneratorScriptPath"
    exit 1
}

$xml = [xml](Get-Content $configFilePath)
if(-not $ListProfile){
    $existingNode = $xml.SelectNodes("//cred[@name='$ProfileName']")
    if($existingNode.Count -eq 0){
        Write-Error "There is no key saved under the profile name : $ProfileName"
    }elseif(@($existingNode).Count -eq 1){
        $code = & $mfaGeneratorScriptPath -Key (New-Object pscredential ('osef',(ConvertTo-SecureString $existingNode.MFAKey))).GetNetworkCredential().Password
        Write-Host $code
        try{
            Set-Clipboard -Value $code
        }catch{
            "$code" | & clip.exe
        }
        Write-Host -ForegroundColor Yellow "Code has been put in the clipboard"
    }else{
        Write-Error "Multiple XML nodes found for profile name : $ProfileName"
        exit
    }
}else{
    $xml.configs.cred | ?{$_.Name -ne "template"} | ft Name
}
