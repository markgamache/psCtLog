function Get-CrlFromHttpCdp([uri] $CDPURI, [int] $tryNum = 0)
{
    
    try
    {
        $ProgressPreference = 'SilentlyContinue' 
        $crl = Invoke-WebRequest $CDPURI
        return [pscustomobject] @{CDPUrl = $CDPURI; Size = $crl.Content.LongLength }

        Write-Host "" -NoNewline
    }
    catch
    {
        if($tryNum -gt 3 )
        {
            return [pscustomobject] @{CDPUrl = $CDPURI; Size = -1 }
        }
        else
        {
            return Get-CrlFromHttpCdp -CDPURI $CDPURI -tryNum ($tryNum + 1)
        
            Write-Host "" -NoNewline
        }
        #throw $_
    }

}