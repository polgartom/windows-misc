$deviceName = "Universal Audio Apollo Thunderbolt"
$processName = "UAMixerEngine"
$deviceStatus = "OK"
$timeoutSeconds = 120

function IsDeviceLoaded() {
    $device = Get-PnpDevice | Where-Object {$_.FriendlyName -like "*$deviceName*" -and $_.Status -eq $deviceStatus}
    return $device -ne $null
}

function IsMixerProcessRunning() {
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    return $process -ne $null
}

Write-Host "[ASIOLinkPro x64]"
Write-Host "Waiting for the '$deviceName' device and '$processName'..."

$elapsedSeconds = 0
while (-not (IsDeviceLoaded) -or -not (IsMixerProcessRunning) -and $elapsedSeconds -lt $timeoutSeconds) {
    Start-Sleep -Seconds 1
    $elapsedSeconds++
}

if ($elapsedSeconds -ge $timeoutSeconds) {
    Write-Host "Timeout waiting for device '$deviceName' to appear or the '$processName' process to run."
} else {
    $device = Get-PnpDevice | Where-Object {$_.FriendlyName -like "*$deviceName*" -and $_.Status -eq $deviceStatus}
    if ($device -and (IsMixerProcessRunning)) {
        Write-Host "Device $($device.FriendlyName) is loaded and status is $($device.Status)."
        Write-Host "$processName is running..."
        
        Write-Host "Starting ASIOLinkPro..."
        Write-Host "We delayed the process run, just to be sure.. (about 10sec)"
        Start-Sleep -Seconds 10
        $appPath = "C:\Program Files (x86)\ASIOLinkPro\x64\asiolinktool.exe"
        Start-Process -FilePath $appPath -NoNewWindow
    } else {
        Write-Host "Device '$deviceName' not found or status is not '$deviceStatus' or the '$processName' is not running."
    }
}

Start-Sleep -Seconds 1;