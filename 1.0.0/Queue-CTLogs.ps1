function Queue-CTLogs([object] $logBase, [string[]] $domainLIst, [System.Collections.Concurrent.ConcurrentQueue[object]] $workQueue)
{
    
    while($true)
    {
        $thisTen = get-TenLogs -logBase $logBase.url -ind $logBase.NextIndex

        foreach($lg in $thisTen)
        {
            $workQueue.Enqueue($lg)
            continue
            
            $uped = $false
            $cc = Decode-extra_data -leaf $lg


            foreach($san in $cc.DnsNameList.Unicode)
            {
                foreach($dom in $domainLIst)
                {
                    if($san -like "*.$($dom)")
                    {
                        Upsert-ToLds -CertToUpsert $cc

                        $uped = $true
                    }
                    Write-Host "" -NoNewline
                }

                if($uped)
                {
                    break
                }
            }


        }

        $logBase.NextIndex = $thisTen[-1].LogIndex + 1

    }


    Write-Host "" -NoNewline
}
