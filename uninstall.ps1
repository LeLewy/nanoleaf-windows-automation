$ErrorActionPreference = "Stop"

Write-Host "Removing Nanoleaf Windows Automation tasks..." -ForegroundColor Cyan
Unregister-ScheduledTask -TaskName "NALE Turn on with PC" -TaskPath "\Nanoleaf\" -Confirm:$false -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName "Nanoleaf Master Watcher" -TaskPath "\Nanoleaf\" -Confirm:$false -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName "NALE Turn off" -TaskPath "\Nanoleaf\" -Confirm:$false -ErrorAction SilentlyContinue

# Try to remove the task folder if empty
try {
    $folder = Get-ScheduledTaskFolder -TaskPath "\Nanoleaf\" -ErrorAction SilentlyContinue
    if ($folder) {
        Unregister-ScheduledTaskFolder -TaskPath "\Nanoleaf\" -Confirm:$false -ErrorAction SilentlyContinue
    }
} catch {}

# Stop running Watcher processes
Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" | Where-Object { $_.CommandLine -like "*NanoleafMasterWatcher*" } | ForEach-Object {
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
}

$targetDir = "C:\Scripts"
if (Test-Path $targetDir) {
    Write-Host "Removing scripts directory ($targetDir)..." -ForegroundColor Cyan
    Remove-Item $targetDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Uninstallation completed successfully!" -ForegroundColor Green
