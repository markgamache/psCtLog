function Convert-extra_data($leaf, [bool] $fullCert)
{
    $certchain = [System.Convert]::FromBase64String($leaf.extra_data)

    $certStart = 0
    for($i = 0;$I -lt 10;$i++)
    {
        if($certchain[$i] -eq 48 -and $certchain[$i +1] -eq 130)
        {
            $certStart = $i
            Write-Host "" -NoNewline
            break
        }
    }
  

    #try and over grap
    $fCertData = [byte[]] ( $certchain[($certStart)..$($certchain.Count - 1)])

    try
    {
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($fCertData)
        #$cert 

            #$certchain[$($certStart + 2)..$($certStart + 3)]
        #Write-Host "" -NoNewline
    }
    catch
    {
        #Write-Host "" -NoNewline
        $certchain[$($certStart + 2)..$($certStart + 3)]
    }

    if($fullCert)
    {

        return $cert
    }
    else
    {
        return Format-Cert -certIn $cert 
    }
}

