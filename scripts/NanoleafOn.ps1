$cfg = Get-Content "C:\Scripts\config.json" -Raw | ConvertFrom-Json
$uri = "http://$($cfg.nanoleaf_ip):$($cfg.nanoleaf_port)/api/v1/$($cfg.nanoleaf_token)/state"
curl.exe -s --connect-timeout 2 --max-time 3 -X PUT $uri -H "Content-Type: application/json" -d "@C:\Scripts\nl_on.json" | Out-Null
