
function get-TenLogs([string] $logBase, [long] $ind)
{
    
    $getEntURL =  "$($logBase)ct/v1/get-entries"
    $oLog = Invoke-WebRequest "$($getEntURL)?start=$($ind)&end=$($ind + 19)"
    $obs = $oLog.Content | ConvertFrom-Json 


    foreach($LE in $obs.entries)
    {

        $lBytes = [System.Convert]::FromBase64String($LE.leaf_input)
        $timeBytes = [byte[]] ( $lBytes[2..9])
        [array]::Reverse($timeBytes)
        $rr = [System.BitConverter]::ToUInt64($timeBytes,0)
        $leafTime = [System.DateTimeOffset]::FromUnixTimeMilliseconds($rr).UtcDateTime

        $LE | Add-Member -MemberType NoteProperty -Name LogDate -Value $leafTime -Force
        $LE | Add-Member -MemberType NoteProperty -Name LogIndex -Value $ind -Force

    }

    return $obs.entries
       
    
    Write-Host "" -NoNewline

}
