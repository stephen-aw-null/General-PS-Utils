# tsync.ps1 - change the system's local timezone
# Parameter(s):
# -TargetTZ: specify the desired timezone in STRING

# Create the function so it can be used by other scripts
function tsync
{
    # Declare the parameter(s)
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [String]
            $TargetTZ
    )
    # Return the identifier of the local timezone
    $LocalTZ=Get-TimeZone | Select-Object -Property Id
    # Specify the time service in use by the system; on nearly every Windows system, this will be W32Time
    $TimeService=Get-Service -Name 'W32Time'
    if ($LocalTZ -notmatch $TargetTZ) {
        Set-TimeZone -Id $TargetTZ
        # If W32Time is not running, start it and register it
        if ($TimeService.status -ne 'Running') {
            Start-Service -Name 'W32Time'
            w32tm /unregister
            w32tm /register
        }
        # Synchronize the time with W32Time and redirect its output to null
        w32tm /resync | Out-Null
        Write-Host 'Local timezone has been changed and synchronized to the target timezone.'   
    }
    else {
        Write-Host 'Local timezone already reflects the target timezone.'
    }
}
