#import ps1 functions (all ps1 files are module members)
gci $PSScriptRoot -filter *.ps1 | %{
    Import-Module $_.FullName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    Export-ModuleMember -Function $_.BaseName
}




#import private script functions


Function Warn
{

    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true, Position=0)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Message
    )
    $stackInfo = Get-PSCallStack

    Write-Warning "$($Message) at $($stackInfo[1].FunctionName) in $($stackInfo[1].Location) "

}
