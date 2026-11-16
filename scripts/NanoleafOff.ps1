$lastEvent = Get-WinEvent -FilterHashtable @{LogName='System'; Id=1074} -MaxEvents 1 -ErrorAction SilentlyContinue
if ($lastEvent -and ($lastEvent.Properties[4].Value -match "neu starten|restart")) { exit }

$cfg = Get-Content "C:\Scripts\config.json" -Raw | ConvertFrom-Json
$uri = "http://$($cfg.nanoleaf_ip):$($cfg.nanoleaf_port)/api/v1/$($cfg.nanoleaf_token)/state"
curl.exe -s --connect-timeout 1 --max-time 1 -X PUT $uri -H "Content-Type: application/json" -d "@C:\Scripts\nl_off.json" | Out-Null
