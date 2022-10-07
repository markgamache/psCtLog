function get-STH([string] $logBase)
{
    $stHURL = "$($logBase)ct/v1/get-sth"
    $sth =  Invoke-WebRequest $stHURL 

    $realSTH = $sth.Content | ConvertFrom-Json

    return $realSTH 

}
