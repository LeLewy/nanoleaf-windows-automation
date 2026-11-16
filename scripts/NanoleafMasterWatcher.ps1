Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinBannerHider {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$cfg = Get-Content "C:\Scripts\config.json" -Raw | ConvertFrom-Json
$apiBase      = "http://$($cfg.nanoleaf_ip):$($cfg.nanoleaf_port)/api/v1/$($cfg.nanoleaf_token)"
$overwolfPath = $cfg.overwolf_path
$gameFolders  = $cfg.game_folders
$nlDesktopExe = Get-ChildItem -Path "$env:LOCALAPPDATA\Programs\Nanoleaf*", "${env:ProgramFiles}\Nanoleaf*", "${env:ProgramFiles(x86)}\Nanoleaf*" -Filter "Nanoleaf Desktop.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

$ignoreNames = @("wallpaper*", "ui32", "*Crash*", "*Report*", "*Cleanup*", "*redist*", "*DXSETUP*", "*BEService*", "*EasyAntiCheat*", "*UbisoftConnect*", "*upc*", "*EADesktop*", "*EABackground*", "*cefsharp*", "*WebHelper*", "*Launcher*", "*Updater*", "*Overlay*", "*Helper*")

Register-ObjectEvent -InputObject ([Microsoft.Win32.SystemEvents]) -EventName "SessionEnding" -MessageData $apiBase -Action {
    $ev = Get-WinEvent -FilterHashtable @{LogName='System'; Id=1074} -MaxEvents 1 -ErrorAction SilentlyContinue
    if (-not ($ev -and ($ev.Properties[4].Value -match "neu starten|restart"))) {
        $url = "$($Event.MessageData)/state"
        curl.exe -s --connect-timeout 1 --max-time 1 -X PUT $url -H "Content-Type: application/json" -d "@C:\Scripts\nl_off.json" | Out-Null
    }
} | Out-Null

$autoStartedOverwolf = $false

while ($true) {
    Get-Process -Name "Overwolf" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -eq "Nanoleaf" -and $_.MainWindowHandle -ne 0 } | ForEach-Object {
        [WinBannerHider]::ShowWindow($_.MainWindowHandle, 0) | Out-Null
    }

    $activeGame = Get-Process | Where-Object {
        $p = $_.Path
        $n = $_.ProcessName
        $p -and ($gameFolders | Where-Object { $p -like $_ }) -and -not ($ignoreNames | Where-Object { $n -like $_ })
    } | Select-Object -First 1

    $owRunning = Get-Process -Name "Overwolf", "OverwolfLauncher" -ErrorAction SilentlyContinue
    $nlRunning = Get-Process -Name "Nanoleaf Desktop" -ErrorAction SilentlyContinue

    if ($activeGame) {
        if (-not $nlRunning -and $nlDesktopExe -and (Test-Path $nlDesktopExe)) {
            Start-Process -FilePath $nlDesktopExe -WindowStyle Minimized
            Start-Sleep -Seconds 3
        }
        if (-not $owRunning -and (Test-Path $overwolfPath)) {
            Start-Process -FilePath $overwolfPath -ArgumentList "-silent"
            $autoStartedOverwolf = $true
        }
    }
    else {
        if ($autoStartedOverwolf -and $owRunning) {
            Start-Sleep -Seconds 5
            $stillPlaying = Get-Process | Where-Object {
                $p = $_.Path
                $n = $_.ProcessName
                $p -and ($gameFolders | Where-Object { $p -like $_ }) -and -not ($ignoreNames | Where-Object { $n -like $_ })
            }
            if (-not $stillPlaying) {
                taskkill.exe /F /IM "Overwolf*" /T 2>$null | Out-Null
                $autoStartedOverwolf = $false
            }
        }
        elseif (-not $owRunning) {
            $autoStartedOverwolf = $false
        }
    }

    Wait-Event -Timeout 2 | Out-Null
}
