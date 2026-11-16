$ErrorActionPreference = "Stop"
$targetDir = "C:\Scripts"
$localConfig = "$PSScriptRoot\config\config.json"

if (-not (Test-Path $localConfig)) {
    Write-Error "Please copy 'config\config.example.json' to 'config\config.json' and enter your Nanoleaf IP and Auth Token first."
    exit 1
}

$cfg = Get-Content $localConfig -Raw | ConvertFrom-Json
if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }
Copy-Item "$PSScriptRoot\scripts\*" $targetDir -Force
Copy-Item "$PSScriptRoot\wrappers\*" $targetDir -Force
Copy-Item "$PSScriptRoot\config\nl_*.json" $targetDir -Force
Copy-Item $localConfig "$targetDir\config.json" -Force

$actionOn = New-ScheduledTaskAction -Execute "wscript.exe" -Argument '"C:\Scripts\LaunchOn.vbs"'
$triggerOn = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "NALE Turn on with PC" -TaskPath "\Nanoleaf\" -Action $actionOn -Trigger $triggerOn -RunLevel Highest -Force | Out-Null

$actionWatcher = New-ScheduledTaskAction -Execute "wscript.exe" -Argument '"C:\Scripts\LaunchWatcher.vbs"'
$triggerWatcher = New-ScheduledTaskTrigger -AtLogOn
$settingsWatcher = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Days 365) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName "Nanoleaf Master Watcher" -TaskPath "\Nanoleaf\" -Action $actionWatcher -Trigger $triggerWatcher -Settings $settingsWatcher -RunLevel Highest -Force | Out-Null

$CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler
$tShutdown = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
$tShutdown.Subscription = "<QueryList><Query Id=`"0`" Path=`"System`"><Select Path=`"System`">*[System[Provider[@Name='User32'] and EventID=1074]]</Select><Suppress Path=`"System`">*[EventData[Data[@Name='param5']='restart' or Data[@Name='param5']='neu starten' or Data[@Name='param5']='redémarrer' or Data[@Name='param5']='reiniciar' or Data[@Name='param5']='riavvia']]</Suppress></Query></QueryList>"
$tShutdown.Enabled = $true

$offUri = "http://$($cfg.nanoleaf_ip):$($cfg.nanoleaf_port)/api/v1/$($cfg.nanoleaf_token)/state"
$actionOff = New-ScheduledTaskAction -Execute "C:\Windows\System32\curl.exe" -Argument "-s --connect-timeout 1 --max-time 1 -X PUT `"$offUri`" -H `"Content-Type: application/json`" -d `"@C:\Scripts\nl_off.json`""
$principalOff = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settingsOff = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Seconds 5)

Register-ScheduledTask -TaskName "NALE Turn off" -TaskPath "\Nanoleaf\" -Action $actionOff -Trigger $tShutdown -Principal $principalOff -Settings $settingsOff -Force | Out-Null
Write-Host "Installation completed successfully!" -ForegroundColor Green
