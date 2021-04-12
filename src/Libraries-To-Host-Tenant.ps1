<#
.SYNOPSIS
	Upload Libraries From $PathLibraries to Host Tenant.

.DESCRIPTION
	Forces libraries back into the Orchestrator Host tenant and rebuilds the related metadata in the Orchestrator DB.

.PARAMETER OrchestratorURL
	URL used to access Orchestrator via browser.

.PARAMETER HostAdminPassword
	Password used to login to Admin user of Host tenant.

.PARAMETER PathLibraries
	Full path to location of libraries.

.EXAMPLE
	PS> .\Libraries-To-Host-Tenant.ps1 `
	-OrchestratorURL "https://cloud.uipath.com/" `
	-HostAdminPassword "password" `
	-PathLibraries "C:\Users\Michael\Libraries\"
#>

Param (
	$OrchestratorURL="",
	$HostAdminPassword="",
	$PathLibraries=""
)
Function WriteLog {
    Param (
        [string] $Message,
        [switch] $Err
    )
    $LogFile = "Libraries-To-Host-Tenant.log"
    If (!(Test-Path $LogFile)) {
        New-Item $LogFile
    }
    $Now = Get-Date -Format "HH:mm:ss"
    $Line = "$Now`t$Message"
    $Line | Add-Content $LogFile -Encoding UTF8
    If ($Err) {
        Write-Host $Line -ForegroundColor Red
    } Else {
        Write-Host $Line
    }
}

WriteLog "STARTED: Libraries-To-Host-Tenant.ps1."

$Counter = 1

Try {
	$Token = Get-UiPathAuthToken -URL $OrchestratorURL -TenantName "Host" -Username "Admin" -Password $HostAdminPassword -Session
	WriteLog "Got UiPath authentication token."

	Get-ChildItem $PathLibraries -Filter *.nupkg -name |
	Foreach-Object {
		$PathJoined = Join-Path -Path $PathLibraries -ChildPath $_
		Add-UiPathLibrary -AuthToken $Token -LibraryPackage $PathJoined
		WriteLog "$Counter - Uploaded library to Host Tenant - $_."
		$Counter++
	}
} Catch {
	WriteLog -Err "ERROR: Uploading libraries to Host tenant."
}

WriteLog "COMPLETED: Libraries-To-Host-Tenant.ps1."
WriteLog "--------------------------------------------------"