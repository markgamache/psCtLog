function Upsert-ToLds([System.Security.Cryptography.X509Certificates.X509Certificate2] $CertToUpsert)
{
    $hasher = [System.Security.Cryptography.SHA256]::Create()
    $cc = $CertToUpsert
    $tHash =  [System.BitConverter]::ToString( $hasher.ComputeHash($cc.RawData)).Replace("-","")
    $isitThere = Get-LDAPObject -LdapServer localhost -SearchBase "CN=certs,DC=ct,DC=logs" -Port 389 -LDAPFilter "(|(precerthash=$($tHash))(certhash=$($tHash)))" -Scope OneLevel 
                        
    #$cc | Add-Member -MemberType NoteProperty -Name Sha256 -Value $tHash -Force


    if($isitThere -eq $null)
    {
        # add it.
        $ccccc = Format-Cert -certIn $cc

        Write-Host $ccccc.DnsNameList

        $keyBytes = [System.Text.Encoding]::ASCII.GetBytes($ccccc.PubKeyHash256)
        $snBytes = [System.Text.Encoding]::ASCII.GetBytes($ccccc.SerialNumber)

        $nameHash = [System.BitConverter]::ToString( $hasher.ComputeHash($keyBytes + $snBytes)).Replace("-","")

        $adObject = New-LDAPObject -LdapServer localhost -Port 389 -obDN "cn=$($nameHash),CN=certs,DC=ct,DC=logs" -objectClass certificate

        if("ObjectExists" -eq $adObject)
        {
            #we already have the object by key hash.
            $dupObj = Get-LDAPObject -LdapServer localhost -SearchBase "cn=$($nameHash),CN=certs,DC=ct,DC=logs" -Port 389  -Scope Base -LDAPFilter "(objectclass=*)"
            if($dupObj.Values.serialnumber -eq $ccccc.SerialNumber -and 
                $dupObj.Values.issuer -eq $ccccc.issuer -and 
                $dupObj.Values.Subject -eq $ccccc.Subject -and 
                $dupObj.Values.dnsnames -eq $ccccc.DnsNameList -and
                $dupObj.Values.pubkeyhash -eq $ccccc.PubKeyHash256)
            {
                #full dupe.  Probaly the cert vs precert
                if($ccccc.IsPreCert -and $dupObj.Values.precerthash -eq $null)
                {
                    Set-LDAPObject -LdapServer localhost -Port 389 -obDN "cn=$($nameHash),CN=certs,DC=ct,DC=logs" -Operation Add -AtributeName precerthash -Value $ccccc.Sha256  | Out-Null
                }
                elseif($ccccc.IsPreCert -eq $false -and $dupObj.Values.certhash -eq $null)
                {
                    Set-LDAPObject -LdapServer localhost -Port 389 -obDN "cn=$($nameHash),CN=certs,DC=ct,DC=logs" -Operation Add -AtributeName certhash -Value $ccccc.Sha256  | Out-Null
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

            continue
        }

        #add attribits
        Set-LDAPObject -LdapServer localhost -Port 389 -obDN $adObject -Operation Add -AtributeName pubKeyHash -Value $ccccc.PubKeyHash256 | Out-Null

        #YYYYMMDDHHMMSS. 0Z

        Set-LDAPObject -LdapServer localhost -Port 389 -obDN $adObject -Operation Add -AtributeName notBefore -Value $ccccc.NotBefore.ToUniversalTime().ToString("yyyyMMddhhmmss.0Z")  | Out-Null
        Set-LDAPObject -LdapServer localhost -Port 389 -obDN $adObject -Operation Add -AtributeName notAfter -Value $ccccc.NotAfter.ToUniversalTime().ToString("yyyyMMddhhmmss.0Z")  | Out-Null

        Set-LDAPObject -LdapServer localhost -Port 389 -obDN $adObject -Operation Add -AtributeName subject -Value $ccccc.subject  | Out-Null
        Set-LDAPObject -LdapServer localhost -Port 389 -obDN $adObject -Operation Add -AtributeName issuer -Value $ccccc.issuer  | Out-Null
        try
        {
            Set-LDAPObject -LdapServer localhost -Port 389 -obDN $adObject -Operation Add -AtributeName dnsnames -Value $ccccc.DnsNameList | Out-Null
        }
        catch
        {
            Write-Host "" -NoNewline
        }

        #serialNumber
        Set-LDAPObject -LdapServer localhost -Port 389 -obDN $adObject -Operation Add -AtributeName serialNumber -Value $ccccc.SerialNumber  | Out-Null

        if($certys.IsPreCert)
        {
            Set-LDAPObject -LdapServer localhost -Port 389 -obDN $adObject -Operation Add -AtributeName precerthash -Value $ccccc.Sha256  | Out-Null
        }
        else
        {
            Set-LDAPObject -LdapServer localhost -Port 389 -obDN $adObject -Operation Add -AtributeName certhash -Value $ccccc.Sha256  | Out-Null
        }


    } #end null

    Write-Host "" -NoNewline

}