function find-IndexAtDate([object] $logBase, [datetime] $date)
{
    $ProgressPreference = 'SilentlyContinue' 
    $sth = get-STH -logBase $logBase.url

    $logBase | Add-Member -MemberType NoteProperty -Name SearchFail -Value $false -Force

    $topInd = 0
    $bottomInd = $sth.tree_size - 1

    $logBase | Add-Member -MemberType NoteProperty -Name LastIndex -Value $bottomInd -Force

    $topLog = get-OneLog -logBase $logBase.url -ind $topInd
    $bottomLog = get-OneLog -logBase $logBase.url -ind $bottomInd

    while($true)
    {
        try
        {

            if($bottomLog.LogIndex - $topLog.LogIndex -eq 1  )
            {
                $logBase | Add-Member -MemberType NoteProperty -Name StartIndex -Value $topLog.LogIndex -Force
                $logBase | Add-Member -MemberType NoteProperty -Name NextIndex -Value $topLog.LogIndex -Force
                #$logBase | Add-Member -MemberType NoteProperty -Name LastFetchedIndex -Value ([long] -1 )
                
                #return $topLog
                #Write-Host "" -NoNewline
                return 
            }
            elseif(($topLog.LogDate -lt $date) -and ($date -lt $bottomLog.LogDate))
            {
                #split and retry
                $midLog = get-OneLog -logBase $logBase.url -ind ((($bottomLog.LogIndex - $topLog.LogIndex) /2) +$topLog.LogIndex)
                #Write-Host "$($topLog.LogDate) $($topLog.LogIndex)"
                #Write-Host "$($midLog.LogDate) $($midLog.LogIndex)"
                #Write-Host "$($bottomLog.LogDate) $($bottomLog.LogIndex)"
                if($midLog.LogDate -gt $date )
                {
                    $bottomLog = $midLog
                    continue
                    Write-Host "" -NoNewline
                }
                elseif($midLog.LogDate -lt $date )
                {
                    $topLog = $midLog
                    continue
                    Write-Host "" -NoNewline
                }
                else
                {

                    Write-Host "" -NoNewline
                }
            }
            elseif(($topLog.LogDate -gt $date) -or ($date -gt $bottomLog.LogDate))
            {
                Write-Warning "$($logBase.url) has no data in your timeframe"
                $logBase.SearchFail = $true
                return 
                Write-Host "" -NoNewline
            }
            else
            {
                #date time whacky
                Write-Warning "$($logBase.url) has something odd about its index"
                $logBase.SearchFail = $true
                return 
                Write-Host "" -NoNewline
            }
        }
        catch
        {
            Write-Host "" -NoNewline
        }
    }


}