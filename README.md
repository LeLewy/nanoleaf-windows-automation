# Nanoleaf Windows Automation

Automated control of Nanoleaf panels and Overwolf on Windows:
- **PC Login:** Activates the configured startup scene (`nl_on.json`) silently without flashing console windows.
- **Gaming Mode:** Launches Nanoleaf Desktop and Overwolf (`-silent`) when a game is detected, hides the Overwolf banner invisibly (`SW_HIDE`), and closes Overwolf 5 seconds after exiting the game (only if auto-started).
- **PC Shutdown:** Turns off the panels on shutdown while keeping them on during reboots.

## Installation
1. Clone or download this repository.
2. Copy `config/config.example.json` to `config/config.json` and fill in your Nanoleaf IP and Auth Token.
3. Open PowerShell **as Administrator** and run `.\install.ps1`.

## Uninstallation
To completely remove all scheduled tasks, background watchers, and the `C:\Scripts` folder:
1. Open PowerShell **as Administrator**.
2. Run `.\uninstall.ps1`.
