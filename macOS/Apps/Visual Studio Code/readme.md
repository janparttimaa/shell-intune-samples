# Visual Studio Code Installation Script

This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Microsoft Visual Studio Code and then install it onto the Mac.

## Scenario

This scripts intended usage scenario is to install Visual Studio Code via the Intune Scripting Agent.

## Quick Run

```
sudo /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/macOS/Apps/Visual%20Studio%20Code/installVSCode.zsh)"
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
# Sat Jan 17 15:36:12 EET 2026 | Logging install of [Visual Studio Code] to [/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.log]
##############################################################

Sat Jan 17 15:36:12 EET 2026 | Checking if we need Rosetta 2 or not
Sat Jan 17 15:36:12 EET 2026 | Waiting for other [/usr/sbin/softwareupdate] processes to end
Sat Jan 17 15:36:12 EET 2026 | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
2026-01-17 15:36:12.905 softwareupdate[745:6806] Package Authoring Error: 093-37389: Package reference com.apple.pkg.RosettaUpdateAuto is missing installKBytes attribute
By using the agreetolicense option, you are agreeing that you have run this tool with the license only option and have read and agreed to the terms.
If you do not agree, press CTRL-C and cancel this process immediately.
Install of Rosetta 2 finished successfully
Sat Jan 17 15:36:16 EET 2026 | Rosetta has been successfully installed.
Sat Jan 17 15:36:16 EET 2026 | Checking if we need to install or update [Visual Studio Code]
Sat Jan 17 15:36:16 EET 2026 | [Visual Studio Code] not installed, need to download and install
Sat Jan 17 15:36:16 EET 2026 | Dock is here, lets carry on
Sat Jan 17 15:36:16 EET 2026 | Starting downloading of [Visual Studio Code]
Sat Jan 17 15:36:16 EET 2026 | Waiting for other [curl -f] processes to end
Sat Jan 17 15:36:17 EET 2026 | No instances of [curl -f] found, safe to proceed
Sat Jan 17 15:36:17 EET 2026 | Downloading Visual Studio Code
Sat Jan 17 15:36:32 EET 2026 | Downloaded file detected as [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.8WxMneFEBG/VSCode-darwin-universal.zip]
Sat Jan 17 15:36:32 EET 2026 | Detected install type as [ZIP]
Sat Jan 17 15:36:32 EET 2026 | Using installer file [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.8WxMneFEBG/VSCode-darwin-universal.zip]
Sat Jan 17 15:36:32 EET 2026 | Waiting for other [/Applications/Visual Studio Code.app/Contents/MacOS/Electron] processes to end
Sat Jan 17 15:36:32 EET 2026 | No instances of [/Applications/Visual Studio Code.app/Contents/MacOS/Electron] found, safe to proceed
Sat Jan 17 15:36:32 EET 2026 | Installing Visual Studio Code
Sat Jan 17 15:36:32 EET 2026 | Changed current directory to /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.8WxMneFEBG
Sat Jan 17 15:36:40 EET 2026 | /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.8WxMneFEBG/VSCode-darwin-universal.zip unzipped
Sat Jan 17 15:36:46 EET 2026 | Visual Studio Code moved into /Applications
Sat Jan 17 15:36:46 EET 2026 | Determining logged-in user for ownership
Sat Jan 17 15:36:46 EET 2026 | Setting ownership of [/Applications/Visual Studio Code.app] to [johndoe:admin]
Sat Jan 17 15:36:47 EET 2026 | Ownership and permissions successfully applied
drwxr-xr-x  3 johndoe  admin  96 Jan 14 17:20 /Applications/Visual Studio Code.app
Sat Jan 17 15:36:47 EET 2026 | Visual Studio Code Installed
Sat Jan 17 15:36:47 EET 2026 | Cleaning Up
Sat Jan 17 15:36:47 EET 2026 | Writing last modifieddate [Wed, 14 Jan 2026 15:56:43 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installVSCode/Visual Studio Code.meta]
Sat Jan 17 15:36:47 EET 2026 | Application [Visual Studio Code] successfully installed

```
