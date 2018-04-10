param(
[Parameter(Mandatory=$true)][String]$Key,
[DateTime]$T0=([DateTime]"1970/01/01"),
[int]$TI=30,
[ValidateRange(1,8)][int]$TokenLength=6
)

function GetBytesFromBase32Chunk {
    param([String]$chunk)
    $hBase32Table=@{
        'A'=0;
        'B'=1;
        'C'=2;
        'D'=3;
        'E'=4;
        'F'=5;
        'G'=6;
        'H'=7;
        'I'=8;
        'J'=9;
        'K'=10;
        'L'=11;
        'M'=12;
        'N'=13;
        'O'=14;
        'P'=15;
        'Q'=16;
        'R'=17;
        'S'=18;
        'T'=19;
        'U'=20;
        'V'=21;
        'W'=22;
        'X'=23;
        'Y'=24;
        'Z'=25;
        '2'=26;
        '3'=27;
        '4'=28;
        '5'=29;
        '6'=30;
        '7'=31;
    }
    $bitsProcessed=0
    $bitRemainingInCurrentByte=8
    $currentByte=0
    $bytesArray=New-Object Byte[] 5
    foreach($char in $chunk.ToCharArray()){
        if("$char" -eq "="){
            break
        }
        #How many bits will be pasted in the current Byte
        $bitsToPaste = [math]::Min(5,$bitRemainingInCurrentByte)

        
        #The value to bor with the current byte 
        #First we shift right to eliminate unneeded bits (none if we paste all the fives)
        #And we shift left to positione our bits as needed (
        $value = $hBase32Table["$char"] -shr (5 - $bitsToPaste) -shl ($bitRemainingInCurrentByte - $bitsToPaste)
        $bytesArray[$currentByte] = $bytesArray[$currentByte] -bor $value
        
        $bitRemainingInCurrentByte = $bitRemainingInCurrentByte - 5
        if($bitRemainingInCurrentByte -le 0){
            $bitRemainingInCurrentByte = 8
            $currentByte+=1
            if($bitsToPaste -lt 5){
                $bitsRemainingToPaste = 5 - $bitsToPaste
                $mask = 0xff -shr (8 - $bitsRemainingToPaste)
                $value = ($hBase32Table["$char"] -band $mask) -shl ($bitRemainingInCurrentByte - $bitsRemainingToPaste)
                $bytesArray[$currentByte] = $bytesArray[$currentByte] -bor $value
                $bitRemainingInCurrentByte = $bitRemainingInCurrentByte - $bitsRemainingToPaste
            }
        }
    }
    $byteArrayLen = [Math]::Floor(($chunk.Replace("=",$null).Length * 5) / 8)
    if($byteArrayLen -eq 5){
        return $bytesArray
    }else{
        return $bytesArray[0..($byteArrayLen-1)]
    }
}

function GetBytesFromBase32String {
    param([String]$s)
    $s = $s.ToUpper()
    $chunkSize=8
    if($s.Length%$chunkSize -ne 0){
        Write-Error "The chain is not Base32 or is missing padding characters"
    }

    $bytes = $null
    
    for($current=0 ; $current + 8 -le $s.Length;$current+=8){
        $bytes+=GetBytesFromBase32Chunk $s.Substring($current,8)
    }
    return $bytes
}


$time = [math]::Floor(([Datetime]::UtcNow - $T0).TotalSeconds)
$count = [math]::Floor($time/$TI)


$hmacsha = [System.Security.Cryptography.KeyedHashAlgorithm]::Create("HMACSHA1")

$byteKey = GetBytesFromBase32String $key
$hmacsha.Key = $byteKey
$byteCount = [System.BitConverter]::GetBytes(([uint64]$count))
[array]::Reverse($byteCount)
$hash = $hmacsha.ComputeHash($byteCount)

$offset = ($hash[-1]) -band 0xf

#All the "-band 0xff" can seems useless but they are not : they convert Bytes into Integers
#Explicit cast could do the trick to...
#$integer = (($hash[$offset] -band 0x7f) -shl 24) -bor (($hash[$offset+1] -band 0xff) -shl 16) -bor (($hash[$offset+2] -band 0xff) -shl 8) -bor ($hash[$offset+3] -band 0xff)
$integer = (($hash[$offset] -band 0x7f) -shl 24) -bor (([int]$hash[$offset+1]) -shl 16) -bor (([int]$hash[$offset+2]) -shl 8) -bor ([int]$hash[$offset+3])
$code = $integer % ([Math]::Pow(10,$TokenLength))

return $code.ToString().PadLeft($TokenLength,"0")

