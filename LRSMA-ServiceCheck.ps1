<#
Script : LogRhythm SMA service restart script.  It checks to see if the service is running, restarts and logs. 
Version: 0.2 
Authour: DLSV.bsky.social 
#>

$serviceName = "LogRhythm System Monitor Service"

$serviceStatus = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($serviceStatus) {
    if ($serviceStatus.Status -ne "Running") {
        Write-Host "Service '$serviceName' is not running. Starting it..."
        Start-Service -Name $serviceName
        Write-Host "Service '$serviceName' has been started."

        $logMessage = "Service '$serviceName' has been started."
        Write-EventLog -LogName "Application" -Source "PowerShell" -EventId 1000 -EntryType Information -Message $logMessage
    }
    else {
        Write-Host "Service '$serviceName' is already running."

        $logMessage = "Service '$serviceName' is already running."
        Write-EventLog -LogName "Application" -Source "PowerShell" -EventId 1000 -EntryType Information -Message $logMessage
    }
}
else {
    Write-Host "Service '$serviceName' does not exist."

    $logMessage = "Service '$serviceName' does not exist."
    Write-EventLog -LogName "Application" -Source "PowerShell" -EventId 1000 -EntryType Error -Message $logMessage
}