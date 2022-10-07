function find-IndexAtDate([string] $logBase, [datetime] $date)
{
    $sth = get-STH -logBase $logBase

    $topInd = 0
    $bottomInd = $sth.tree_size - 1

    $topLog = get-OneLog -logBase $logBase -ind $topInd
    $bottomLog = get-OneLog -logBase $logBase -ind $bottomInd

    while($true)
    {
        

        if($bottomLog.LogIndex - $topLog.LogIndex -eq 1  )
        {
            return $topLog
            Write-Host "" -NoNewline
        }
        elseif(($topLog.LogDate -lt $date) -and ($date -lt $bottomLog.LogDate))
        {
            #split and retry
            $midLog = get-OneLog -logBase $logBase -ind ((($bottomLog.LogIndex - $topLog.LogIndex) /2) +$topLog.LogIndex)
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
        else
        {

            Write-Host "" -NoNewline
        }

    }


}