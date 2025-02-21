function Get-CDPfromCert([System.Security.Cryptography.X509Certificates.X509Certificate2] $certIn)
{
    $hasherX = [System.Security.Cryptography.SHA256]::Create() 
    $isPrecert = $false
    $isCA = $false

    foreach($ext in $certIn.Extensions)
    {
        if($ext.Oid.Value -eq "1.3.6.1.4.1.11129.2.4.3")
        {
            $isPrecert = $true
            
        }

        if($ext.Oid.Value -eq "2.5.29.19")
        {
            $isCA = $ext.CertificateAuthority
            
        }

        if($ext.Oid.Value -eq "2.5.29.31")
        {
            $asnData = [System.Security.Cryptography.AsnEncodedData]::new($ext.OID.Value, $ext.RawData)
            $better = $asnData.Format($false).Split("()")

            $outarr = [System.Collections.Generic.List[string]]::new()
            


            if($better.Count -eq 1)
            {
                if($asnData.Format($false).Contains("[2]"))
                {
                    $better = $asnData.Format($false).Split("[]=,")
                    foreach($p in $better)
                    {
                        try
                        {
                            $CDPUri = [uri]::new($p)
                            $outarr.Add($CDPUri.AbsoluteUri)

                        }
                        catch
                        {
                            Write-Host "" -NoNewline
                    
                        }
                    }
                    return $outarr.ToArray()
                    Write-Host "" -NoNewline
                }
                else
                {
                    $outarr.Add([string] $asnData.Format($false).Split("=")[-1])
                }

                return $outarr.ToArray()
            }


            foreach($p in $better)
            {
                try
                {
                    $CDPUri = [uri]::new($p)
                    $outarr.Add($CDPUri.AbsoluteUri)

                }
                catch
                {
                    Write-Host "" -NoNewline
                    
                }
            }

            return $outarr.ToArray()
                  
            
        }

    }


}