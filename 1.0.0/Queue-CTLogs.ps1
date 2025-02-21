function Queue-CTLogs([object] $logBase, [string[]] $domainLIst, [System.Collections.Concurrent.ConcurrentQueue[object]] $workQueue, [System.Collections.Concurrent.ConcurrentQueue[int16]] $counter)
{
    $ProgressPreference = 'SilentlyContinue'    
    
    while($true)
    {
        $thisTen = get-TenLogs -logBase $logBase.url -ind $logBase.NextIndex -qty 50 -counter $counter

        foreach($lg in $thisTen)
        {
            $cc = Convert-extra_data -leaf $lg -fullCert $false

            if($cc.bIsCa -eq $false)
            {

                foreach($san in $cc.DnsNameArray)
                {
                    #Write-Host "$($san) $($logBase.url) $($lg.LogIndex) $($lg.LogDate) $($cc.RawDataHash) "
                    foreach($dom in $domainLIst)
                    {

                        if($dom.StartsWith("."))
                        {
                            #we look at whole domain

                            $baseNoDot = [string]($dom.Substring(1, $dom.Length -1))

                            if($san -like "*$($dom)" -or $san -eq ($baseNoDot))
                            {
                                $workQueue.Enqueue($cc) | Out-Null

                                $uped = $true
                            }
                        }
                        else
                        {
                            #this is an FQDN
                            if($san -eq $dom)
                            {
                                $workQueue.Enqueue($cc) | Out-Null

                                $uped = $true
                            }
                        }
                        
                        #Write-Host "" -NoNewline
                    }

                    if($uped)
                    {
                        break
                    }
                }

                                
            }
            else
            {
                $rrr= ""
            }

            $logBase.NextIndex = $thisTen[-1].LogIndex + 1


            if($logBase.NextIndex -gt $logBase.LastIndex)
            {
                #Write-Host "" -NoNewline
                return
            }

       
   
            continue
            
            $uped = $false
            $cc = Convert-extra_data -leaf $lg


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

        Write-Host "$($san) $($logBase.url) $($lg.LogIndex) $($lg.LogDate) $($cc.RawDataHash) "
    }


    #Write-Host "" -NoNewline
}
