
function get-TenLogs([object] $logBase, [long] $ind, [int] $qty = 10, [System.Collections.Concurrent.ConcurrentQueue[object]] $workQueue)
{
    $ProgressPreference = 'SilentlyContinue'    
    $getEntURL =  "$($logBase.url)ct/v1/get-entries"

    try
    {
        $stopwatchSW = [System.Diagnostics.Stopwatch]::new()
        $stopwatchSW.Start()
        $fullURL = "$($getEntURL)?start=$($ind)&end=$($ind + $qty - 1 )"
        $oLog = Invoke-WebRequest $fullURL  -UseBasicParsing 

        $stopwatchSW.Stop()

        if($stopwatchSW.ElapsedMilliseconds -gt 2000)
        {
            Write-Warning "$($logBase.url) is slow. $($stopwatchSW.ElapsedMilliseconds) ms to get $($qty)"
        }
    }
    Catch
    {
        
        if($_.Exception.Message -like "*429*")
        {
            Write-Warning "Being throttled by $($logBase.url). Pausing"

                      
            Start-Sleep -Milliseconds 500
            return get-TenLogs -logBase $logBase -ind $ind -qty $qty
        }
        else
        {
            Write-Warning "Hm fail at get-TenLogs fetch $($fullURL) $($_.Exception.Message)" 
            Write-Host "" -NoNewline

            
            
            #$_
        }
        
    }
    
    try
    {
        $obs = $oLog.Content | ConvertFrom-Json -ErrorAction SilentlyContinue

        $count = 0

        foreach($LE in $obs.entries)
        {

            $lBytes = [System.Convert]::FromBase64String($LE.leaf_input)
            $timeBytes = [byte[]] ( $lBytes[2..9])
            [array]::Reverse($timeBytes)
            $rr = [System.BitConverter]::ToUInt64($timeBytes,0)
            $leafTime = [System.DateTimeOffset]::FromUnixTimeMilliseconds($rr).UtcDateTime

        

            $LE | Add-Member -MemberType NoteProperty -Name LogDate -Value $leafTime -Force
            $LE | Add-Member -MemberType NoteProperty -Name LogIndex -Value ($ind + $count ) -Force

            $count++

        
         }

        $logBase.NextIndex = $obs.entries[-1].LogIndex + 1 

        return $obs.entries
       
    }
    catch
    {
        $stack = (Get-PSCallStack) | ConvertTo-Json 
        Write-Warning "Hm fail at get-TenLogs fetch $($fullURL) $($_.Exception.Message)" 
    }
    #Write-Host "" -NoNewline

}
