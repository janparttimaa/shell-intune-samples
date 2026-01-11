# Visual Studio Code Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Microsoft Visual Studio Code and then install it onto the Mac.

## Scenario

This scripts intended usage scenario is to install Visual Studio Code via the Intune Scripting Agent.

## Quick Run

```
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Visual%20Studio%20Code/installVSCode.zsh)"
```

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sun Jan 11 15:16:50 EET 2026 | Logging install of [Visual Studio Code] to [/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.log]
##############################################################

Sun Jan 11 15:16:50 EET 2026 | Checking if we need Rosetta 2 or not
Sun Jan 11 15:16:50 EET 2026 | Waiting for other [/usr/sbin/softwareupdate] processes to end
Sun Jan 11 15:16:50 EET 2026 | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Sun Jan 11 15:16:50 EET 2026 | Rosetta is already installed and running. Nothing to do.
Sun Jan 11 15:16:50 EET 2026 | Checking if we need to install or update [Visual Studio Code]
Sun Jan 11 15:16:50 EET 2026 | [Visual Studio Code] not installed, need to download and install
Sun Jan 11 15:16:50 EET 2026 | Dock is here, lets carry on
Sun Jan 11 15:16:50 EET 2026 | Starting downloading of [Visual Studio Code]
Sun Jan 11 15:16:50 EET 2026 | Waiting for other [curl -f] processes to end
Sun Jan 11 15:16:50 EET 2026 | No instances of [curl -f] found, safe to proceed
Sun Jan 11 15:16:50 EET 2026 | Downloading Visual Studio Code
Sun Jan 11 15:17:06 EET 2026 | Downloaded file detected as [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.Iml5KaI0HF/VSCode-darwin-universal.zip]
Sun Jan 11 15:17:06 EET 2026 | Detected install type as [ZIP]
Sun Jan 11 15:17:06 EET 2026 | Using installer file [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.Iml5KaI0HF/VSCode-darwin-universal.zip]
Sun Jan 11 15:17:06 EET 2026 | Waiting for other [/Applications/Visual Studio Code.app/Contents/MacOS/Electron] processes to end
Sun Jan 11 15:17:06 EET 2026 | No instances of [/Applications/Visual Studio Code.app/Contents/MacOS/Electron] found, safe to proceed
Sun Jan 11 15:17:06 EET 2026 | Installing Visual Studio Code
Sun Jan 11 15:17:06 EET 2026 | Changed current directory to /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.Iml5KaI0HF
Sun Jan 11 15:17:13 EET 2026 | /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.Iml5KaI0HF/VSCode-darwin-universal.zip unzipped
Sun Jan 11 15:17:21 EET 2026 | Visual Studio Code moved into /Applications
Sun Jan 11 15:17:21 EET 2026 | Determining logged-in user for ownership
Sun Jan 11 15:17:21 EET 2026 | Setting ownership of [/Applications/Visual Studio Code.app] to [johndoe:staff]
Sun Jan 11 15:17:22 EET 2026 | Ownership and permissions successfully applied
drwxr-xr-x  3 johndoe  staff  96 Jan  8 16:16 /Applications/Visual Studio Code.app
Sun Jan 11 15:17:22 EET 2026 | Visual Studio Code Installed
Sun Jan 11 15:17:22 EET 2026 | Cleaning Up
Sun Jan 11 15:17:23 EET 2026 | Writing last modifieddate [Thu, 08 Jan 2026 14:49:20 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.meta]
Sun Jan 11 15:17:23 EET 2026 | Application [Visual Studio Code] successfully installed

```
