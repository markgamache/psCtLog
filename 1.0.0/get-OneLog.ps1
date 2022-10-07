
function get-OneLog([string] $logBase, [long] $ind)
{
    
    $getEntURL =  "$($logBase)ct/v1/get-entries"
    $oLog = Invoke-WebRequest "$($getEntURL)?start=$($ind)&end=$($ind)"
    $obs = $oLog.Content | ConvertFrom-Json 

    $lBytes = [System.Convert]::FromBase64String($obs.entries[0].leaf_input)
    $timeBytes = [byte[]] ( $lBytes[2..9])
    [array]::Reverse($timeBytes)
    $rr = [System.BitConverter]::ToUInt64($timeBytes,0)
    $leafTime = [System.DateTimeOffset]::FromUnixTimeMilliseconds($rr).UtcDateTime

    $obs.entries[0] | Add-Member -MemberType NoteProperty -Name LogDate -Value $leafTime -Force
    $obs.entries[0] | Add-Member -MemberType NoteProperty -Name LogIndex -Value $ind -Force

    return $obs.entries[0]
       
    
    Write-Host "" -NoNewline

}
