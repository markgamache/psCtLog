function Format-Cert([System.Security.Cryptography.X509Certificates.X509Certificate2] $certIn)
{
    $hasher = [System.Security.Cryptography.SHA256]::Create()
    $isPrecert = $false

    foreach($ext in $certIn.Extensions)
    {
        if($ext.Oid.Value -eq "1.3.6.1.4.1.11129.2.4.3")
        {
            $isPrecert = $true
            continue
        }
    }

    $MinimalCertificate = [pscustomobject] @{ NotAfter = $certIn.NotAfter;
                                                NotBefore = $certIn.NotBefore;
                                                SerialNumber = $certIn.SerialNumber;
                                                Issuer = $certIn.Issuer;
                                                Subject = $certIn.Subject;
                                                Thumbprint = $certIn.Thumbprint;
                                                IsPreCert = $isPrecert;
                                                DnsNameList = (([string[]]$certIn.DnsNameList.Unicode ) | Sort-Object) -join ";";
                                                PubKeyHash256 =  [System.BitConverter]::ToString( $hasher.ComputeHash($certIn.GetPublicKey())).Replace("-","")
                                                Sha256 = [System.BitConverter]::ToString( $hasher.ComputeHash($cc.RawData)).Replace("-","")

                                                
                                            }

    return $MinimalCertificate

    Write-Host "" -NoNewline
}