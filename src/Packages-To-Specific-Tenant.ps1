<#
.SYNOPSIS
	Upload Packages From $PathPackages to Specific Tenant.

.DESCRIPTION
	Forces packages back into a specific Orchestrator tenant and rebuilds the related metadata in the Orchestrator DB. This is ran once per tenant.

.PARAMETER OrchestratorURL
	URL used to access Orchestrator via browser.

.PARAMETER HostAdminPassword
	Password used to login to Admin user of Host tenant.

.PARAMETER Tenant
	Specific tenant to force packages into.

.PARAMETER PathPackages
	Full path to location of packages.

.EXAMPLE
	PS> .\Packages-To-Specific-Tenant.ps1 `
	-OrchestratorURL "https://cloud.uipath.com/" `
	-HostAdminPassword "password" `
	-Tenant "Default" `
	-PathPackages "C:\Users\Michael\Packages\"
#>

Param (
	$OrchestratorURL="",
	$HostAdminPassword="",
	$Tenant="",
	$PathPackages=""
)

Function WriteLog {
    Param (
        [string] $Message,
        [switch] $Err
    )
    $LogFile = "Packages-To-Specific-Tenant.log"
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

$Counter = 1

WriteLog "STARTED: Packages-To-Specific-Tenant.ps1."

Try {
	$Token = Get-UiPathAuthToken -URL $OrchestratorURL -TenantName $Tenant -Username "Admin" -Password $HostAdminPassword -Session
	WriteLog "Got UiPath authentication token."

	Get-ChildItem $PathPackages -Filter *.nupkg -name |
	Foreach-Object {
		$PathJoined = Join-Path -Path $PathPackages -ChildPath $_
		Add-UiPathPackage -AuthToken $Token -Package $PathJoined
    	WriteLog "$Counter - Uploaded package to $Tenant tenant - $_."
    	$Counter++
	}
} Catch {
	WriteLog -Err "ERROR: Uploading packages to $Tenant tenant."
}

WriteLog "STARTED: Packages-To-Specific-Tenant.ps1."
WriteLog "--------------------------------------------------"