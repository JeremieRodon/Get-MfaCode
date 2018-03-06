param(
[Parameter(ParameterSetName='addCred',Mandatory=$true,Position=1)][String]$ProfileName,
[Parameter(ParameterSetName='listCred',Mandatory=$true)][switch]$ListProfile
)


$configFilePath = "$($env:HOMEDRIVE)$($env:HOMEPATH)\saved-MFAs.dat"
$mfaGeneratorScriptPath = "$($env:HOMEDRIVE)$($env:HOMEPATH)\TOTP.ps1"

if(-not (Test-Path -Path $configFilePath -PathType Leaf)){
    Write-Error "Impossible de trouver $configFilePath"
    exit 1
}
if(-not (Test-Path -Path $mfaGeneratorScriptPath -PathType Leaf)){
    Write-Error "Impossible de trouver $mfaGeneratorScriptPath"
    exit 1
}

$xml = [xml](Get-Content $configFilePath)
if(-not $ListProfile){
    $existingNode = $xml.SelectNodes("//cred[@name='$ProfileName']")
    if($existingNode.Count -eq 0){
        Write-Error "Aucune clef sauvegardée sous le nom $ProfileName"
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
        Write-Error "Plusieurs noeuds existent avec le nom $ProfileName"
        exit
    }
}else{
    $xml.configs.cred | ?{$_.Name -ne "template"} | ft Name
}