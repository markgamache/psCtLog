
function get-OneLog([uri] $logBase, [long] $ind)
{
    $ProgressPreference = 'SilentlyContinue'    
    $getEntURL =  "$($logBase)ct/v1/get-entries"

    try
    {
        $Error.Clear()
        $oLog = Invoke-WebRequest "$($getEntURL)?start=$($ind)&end=$($ind)" -UseBasicParsing
        $obs = $oLog.Content | ConvertFrom-Json 

        $lBytes = [System.Convert]::FromBase64String($obs.entries[0].leaf_input)
        $timeBytes = [byte[]] ( $lBytes[2..9])
        [array]::Reverse($timeBytes)
        $rr = [System.BitConverter]::ToUInt64($timeBytes,0)
        $leafTime = [System.DateTimeOffset]::FromUnixTimeMilliseconds($rr).UtcDateTime

        $obs.entries[0] | Add-Member -MemberType NoteProperty -Name LogDate -Value $leafTime -Force
        $obs.entries[0] | Add-Member -MemberType NoteProperty -Name LogIndex -Value $ind -Force

        return $obs.entries[0]
       
    
        #Write-Host "" -NoNewline
    }
    catch
    {
        if($_.Exception.Message -like "*429*")
        {
            Write-Warning "Being throttled by $($logBase). Pausing"
            Start-Sleep -Milliseconds 500
            return get-OneLog -logBase $logBase -ind $ind
        }
        else
        {
            $_
        }
    }

}
