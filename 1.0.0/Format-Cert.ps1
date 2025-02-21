function Format-Cert([System.Security.Cryptography.X509Certificates.X509Certificate2] $certIn)
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
    }

    #Write-Host "" -NoNewline

    $pubKeyHash = $hasherX.ComputeHash($certIn.GetPublicKey())
    #$hasherX.Clear()
    $Sha256hash = $hasherX.ComputeHash($certIn.RawData)

    

    $MinimalCertificate = [pscustomobject] @{ NotAfter = $certIn.NotAfter;
                                                NotBefore = $certIn.NotBefore;
                                                SerialNumber = $certIn.SerialNumber;
                                                Issuer = $certIn.Issuer;
                                                Subject = $certIn.Subject;
                                                Thumbprint = $certIn.Thumbprint;
                                                IsPreCert = $isPrecert;
                                                DnsNameList = (([string[]]$certIn.DnsNameList.Unicode ) | Sort-Object) -join ";";
                                                DnsNameArray = ([string[]]$certIn.DnsNameList.Unicode ) ;
                                                PubKeyHash256 =  [System.BitConverter]::ToString( $pubKeyHash).Replace("-","");
                                                Sha256 = [System.BitConverter]::ToString( $Sha256hash ).Replace("-","");
                                                bIsCa = $isCA
                                                
                                            }

    $keyBytes = [System.Text.Encoding]::ASCII.GetBytes($MinimalCertificate.PubKeyHash256)
    $snBytes = [System.Text.Encoding]::ASCII.GetBytes($MinimalCertificate.SerialNumber)
    $dnsNameBytes = [System.Text.Encoding]::ASCII.GetBytes($MinimalCertificate.DnsNameList)
    $IssuerBytes = [System.Text.Encoding]::ASCII.GetBytes($MinimalCertificate.Issuer)
    $SubjectBytes = [System.Text.Encoding]::ASCII.GetBytes($MinimalCertificate.Subject)

    $NotBeforeBytes = [System.Text.Encoding]::ASCII.GetBytes($MinimalCertificate.NotBefore.ToFileTimeUtc())
    $NotAfterBytes = [System.Text.Encoding]::ASCII.GetBytes($MinimalCertificate.NotAfter.ToFileTimeUtc())


    $nameHash = [System.BitConverter]::ToString( $hasherX.ComputeHash($keyBytes + $snBytes + $dnsNameBytes + $IssuerBytes + $SubjectBytes + $NotBeforeBytes + $NotAfterBytes)).Replace("-","")

    $MinimalCertificate | Add-Member -MemberType NoteProperty -Name RawDataHash -Value $nameHash -Force

    return $MinimalCertificate

    #Write-Host "" -NoNewline
}