<#
.SYNOPSIS
    Prepare Environment for NuGet and Orchestrator Scripting.

.DESCRIPTION
    Prepares the Orchestrator web server to programmatically utilize NuGet and Orchestrator API scripting (requires Administrator credentials).
    The NuGet package provider should get stored in "C:\Program Files\PackageManagement\ProviderAssemblies\nuget".
    The UiPath.PowerShell module should get stored in "C:\Program Files\WindowsPowerShell\Modules\UiPath.PowerShell".

.EXAMPLE
    PS> .\Prepare-Environment.ps1
#>

Function WriteLog {
    Param (
        [string] $Message,
        [switch] $Err
    )
    $LogFile = "Prepare-Environment.log"
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

WriteLog "STARTED: Prepare-Environment.ps1."

Try {
    Install-PackageProvider -Name NuGet -Force
    WriteLog "Installed NuGet package provider."

    Register-PSRepository -Name UiPath -SourceLocation https://www.myget.org/F/uipath-dev/api/v2
    WriteLog "Registered UiPath PowerShell repository."

    Install-Module -Repository UiPath -Name UiPath.Powershell -Force
    WriteLog "Installed UiPath.PowerShell module."

    Import-Module UiPath.PowerShell 2>&1
    WriteLog "Imported UiPath.PowerShell module."
} Catch {
    WriteLog -Err "ERROR: Preparing environment."
}

WriteLog "COMPLETED: Prepare-Environment.ps1."
WriteLog "--------------------------------------------------"