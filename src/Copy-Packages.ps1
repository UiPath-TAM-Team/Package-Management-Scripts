<#
.SYNOPSIS
    Copy Packages from $PathFrom to $PathTo.

.PARAMETER PathFrom
    Full path to old location of packages.

.PARAMETER PathTo
    Full path to new location for packages.

.EXAMPLE
    PS> .\Copy-Packages.ps1 `
    -PathFrom "C:\Users\Michael\Old\" `
    -PathTo "C:\Users\Michael\New\"
#>

Param (
    $PathFrom="",
    $PathTo=""
)

Function WriteLog {
    Param (
        [string] $Message,
        [switch] $Err
    )
    $LogFile = "Copy-Packages.log"
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

WriteLog "STARTED: Copy-Packages.ps1."

$Counter = 1

Try {
    Get-ChildItem $PathFrom -Filter *.nupkg -Recurse -Name |
    Foreach-Object {
        $PathJoined = Join-Path -Path $PathFrom -ChildPath $_
        Copy-Item -Path $PathJoined -Destination $PathTo -Force
        WriteLog "$Counter - Copied package - $_."
        $Counter++
    }
} Catch {
    WriteLog -Err "ERROR: Copying packages."
}

WriteLog "COMPLETED: Copy-Packages.ps1."
WriteLog "--------------------------------------------------"