# Nanoleaf Windows Automation

Automated background control of Nanoleaf panels and Overwolf on Windows—designed to keep your setup fully automated without manual intervention.

## Why use this?
If you own Nanoleaf panels and use Overwolf while gaming, you probably know the routine: manually launching desktop apps, turning on ambient lighting scenes every time you log in, dealing with annoying promotional overlays, and remembering to turn off your lights when shutting down your PC. 

This project completely automates that workflow in the background with zero resource overhead:
- **PC Login:** Silently activates your preferred startup scene (`nl_on.json`) the moment you log into Windows, without flashing command prompt windows.
- **Smart Gaming Mode:** Detects when you launch a game (across Steam, EA, Ubisoft, Xbox, Riot, etc.), automatically starts Nanoleaf Desktop minimized and opens Overwolf in `-silent` mode.
- **Banner Hiding:** Automatically intercepts and hides the intrusive Overwolf promotional banner (`SW_HIDE`) the second it appears.
- **Smart Cleanup:** Automatically closes Overwolf 5 seconds after you exit your game (only if it was auto-started by the script).
- **PC Shutdown Control:** Turns off your Nanoleaf panels when you shut down your PC, while intelligently keeping them powered on during standard reboots.

## Installation
1. Clone or download this repository.
2. Copy `config/config.example.json` to `config/config.json` and fill in your Nanoleaf IP and Auth Token.
3. Open PowerShell **as Administrator** and run `.\install.ps1`.

## Uninstallation
To completely remove all scheduled tasks, background watchers, and the `C:\Scripts` folder:
1. Open PowerShell **as Administrator**.
2. Run `.\uninstall.ps1`.
