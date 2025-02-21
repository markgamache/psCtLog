function get-STH([string] $logBase)
{
    $ProgressPreference = 'SilentlyContinue'   
    
    try
    {
     
        $stHURL = "$($logBase)ct/v1/get-sth"
        $sth =  Invoke-WebRequest $stHURL  -UseBasicParsing
    }
    catch
    {
        if($_.Exception.Message -like "*429*")
        {
            Write-Warning "Being throttled by $($logBase). Pausing"

           
            Start-Sleep -Milliseconds 500
            return get-STH -logBase $logBase 
        }
        else
        {
            
        }
    }

    $realSTH = $sth.Content | ConvertFrom-Json

    return $realSTH 

}
