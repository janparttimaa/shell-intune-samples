# Microsoft Azure Storage Explorer
This page provides you following options for deployment:

a.) [Deploy app using Installation Script](#a-deploy-app-using-installation-script)<br>
b.) [Deploy app to Company Portal to be available](#b-deploy-app-to-company-portal-to-be-available)

## a.) Deploy app using Installation Script
This script is an example to show how to use [Intune Shell Scripting](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts) to install applications. In this case the script will download Microsoft Microsoft Azure Storage Explorer and then install it onto the Mac.

### Scenario
This scripts intended usage scenario is to install Microsoft Azure Storage Explorer via the Intune Scripting Agent. Microsoft Azure Storage Explorer will be installed as required app.

### Quick Run
```
sudo /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/master/macOS/Apps/Microsoft%20Azure%20Storage%20Explorer/installMicrosoftAzureStorageExplorer.zsh)"
```

### Script Settings
- Run script as signed-in user : No
- Hide script notifications on devices : Not configured
- Script frequency : Not configured
- Mac number of times to retry if script fails : 3

### Log File
The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installMicrosoftAzureStorageExplorer/Microsoft Azure Storage Explorer.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sun Jan 11 15:48:08 EET 2026 | Logging install of [Microsoft Azure Storage Explorer] to [/Library/Logs/Microsoft/IntuneScripts/installMicrosofAzureStorageExplorer/Microsoft Azure Storage Explorer.log]
##############################################################

Sun Jan 11 15:48:08 EET 2026 | Checking if we need Rosetta 2 or not
Sun Jan 11 15:48:08 EET 2026 | Waiting for other [/usr/sbin/softwareupdate] processes to end
Sun Jan 11 15:48:08 EET 2026 | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Sun Jan 11 15:48:08 EET 2026 | Rosetta is already installed and running. Nothing to do.
Sun Jan 11 15:48:08 EET 2026 | Checking if we need to install or update [Microsoft Azure Storage Explorer]
Sun Jan 11 15:48:08 EET 2026 | [Microsoft Azure Storage Explorer] not installed, need to download and install
Sun Jan 11 15:48:08 EET 2026 | Dock is here, lets carry on
Sun Jan 11 15:48:08 EET 2026 | Starting downloading of [Microsoft Azure Storage Explorer]
Sun Jan 11 15:48:08 EET 2026 | Waiting for other [curl -f] processes to end
Sun Jan 11 15:48:08 EET 2026 | No instances of [curl -f] found, safe to proceed
Sun Jan 11 15:48:08 EET 2026 | Downloading Microsoft Azure Storage Explorer
Sun Jan 11 15:48:22 EET 2026 | Downloaded file detected as [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.njn5QBnliG/StorageExplorer-darwin-arm64.zip]
Sun Jan 11 15:48:22 EET 2026 | Detected install type as [ZIP]
Sun Jan 11 15:48:22 EET 2026 | Using installer file [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.njn5QBnliG/StorageExplorer-darwin-arm64.zip]
Sun Jan 11 15:48:22 EET 2026 | Waiting for other [/Applications/Microsoft Azure Storage Explorer.app/Contents/MacOS/Electron] processes to end
Sun Jan 11 15:48:22 EET 2026 | No instances of [/Applications/Microsoft Azure Storage Explorer.app/Contents/MacOS/Electron] found, safe to proceed
Sun Jan 11 15:48:22 EET 2026 | Installing Microsoft Azure Storage Explorer
Sun Jan 11 15:48:22 EET 2026 | Changed current directory to /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.njn5QBnliG
Sun Jan 11 15:48:28 EET 2026 | /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.njn5QBnliG/StorageExplorer-darwin-arm64.zip unzipped
Sun Jan 11 15:48:35 EET 2026 | Microsoft Azure Storage Explorer moved into /Applications
Sun Jan 11 15:48:36 EET 2026 | Determining logged-in user for ownership
Sun Jan 11 15:48:36 EET 2026 | Setting ownership of [/Applications/Microsoft Azure Storage Explorer.app] to [johndoe:admin]
Sun Jan 11 15:48:37 EET 2026 | Ownership and permissions successfully applied
drwxr-xr-x  3 johndoe  admin  96 Nov  1 02:22 /Applications/Microsoft Azure Storage Explorer.app
Sun Jan 11 15:48:37 EET 2026 | Microsoft Azure Storage Explorer Installed
Sun Jan 11 15:48:37 EET 2026 | Cleaning Up
Sun Jan 11 15:48:37 EET 2026 | Writing last modifieddate [Tue, 04 Nov 2025 01:08:44 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installMicrosofAzureStorageExplorer/Microsoft Azure Storage Explorer.meta]
Sun Jan 11 15:48:37 EET 2026 | Application [Microsoft Azure Storage Explorer] successfully installed

```

## b.) Deploy app to Company Portal to be available
As Microsoft Azure Storage Explorer installer is not yet available as official PKG-installer, we provide you workaround how to deploy Microsoft Azure Storage Explorer to Company Portal to be available for those users, that needs it. This workaround will always install latest version of Microsoft Azure Storage Explorer from Company Portal.

We use this workaround [payloadless package](/macOS/Apps/Payloadless/) and deployment script. To make your deployment little bit easier, we have pre-created payloadless package already, that you can use.

### Deployment Process:
Use unmanaged macOS PKG app deployment: [More information](https://learn.microsoft.com/en-us/intune/intune-service/apps/macos-unmanaged-pkg)

Here are the detailed details (see below). After setting those up, just deploy application to be available either all users/devices or selected users using security group.

#### App information
| Setting | Value | Notes |
| -------- | ------- | ------- |
| Select file to update | ```StorageExplorer.pkg``` | [Download the pkg file here](StorageExplorer.pkg) and upload that. |
| Name | ```Microsoft Azure Storage Explorer``` ||
| Description | ```Microsoft Azure Storage Explorer is a graphical tool for macOS that allows users to easily manage Azure Storage resources, including blobs, files, queues, and tables, from a single interface. Note: This application always deploys latest version of Microsoft Azure Storage Explorer.``` ||
| Publisher | ```Microsoft Corporation``` ||
| Category | ```Data management``` ||
| Information URL | ```https://learn.microsoft.com/en-us/azure/storage/storage-explorer/vs-azure-tools-storage-manage-with-storage-explorer?tabs=macos``` ||
| Privacy URL | ```https://www.microsoft.com/en-us/privacy/privacystatement``` ||
| Developer | ```Microsoft Corporation``` ||
| Notes | ```Deploys only installer for Apple silicon.``` ||
| Logo | *Logo of the application* | [Download logo here](Microsoft%20Azure%20Storage%20Explorer.png) and upload that.|

#### Program
**Post-install script:**
```
#!/bin/zsh
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/macOS/Apps/Microsoft%20Azure%20Storage%20Explorer/installMicrosoftAzureStorageExplorer.zsh)"
```

#### Requirements
For minimum operating system, select latest version, that is available on the drop-down menu.

#### Detection rules
**Ignore app version:** Yes

**Included apps:**
| App bundle ID (CFBundleIdentifier)| App version (CFBundleShortVersionString) |
| -------- | ------- |
| ```com.microsoft.StorageExplorer``` | ```1.0``` |

### Log File
The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/installMicrosoftAzureStorageExplorer/Microsoft Azure Storage Explorer.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sun Jan 11 15:48:08 EET 2026 | Logging install of [Microsoft Azure Storage Explorer] to [/Library/Logs/Microsoft/IntuneScripts/installMicrosofAzureStorageExplorer/Microsoft Azure Storage Explorer.log]
##############################################################

Sun Jan 11 15:48:08 EET 2026 | Checking if we need Rosetta 2 or not
Sun Jan 11 15:48:08 EET 2026 | Waiting for other [/usr/sbin/softwareupdate] processes to end
Sun Jan 11 15:48:08 EET 2026 | No instances of [/usr/sbin/softwareupdate] found, safe to proceed
Sun Jan 11 15:48:08 EET 2026 | Rosetta is already installed and running. Nothing to do.
Sun Jan 11 15:48:08 EET 2026 | Checking if we need to install or update [Microsoft Azure Storage Explorer]
Sun Jan 11 15:48:08 EET 2026 | [Microsoft Azure Storage Explorer] not installed, need to download and install
Sun Jan 11 15:48:08 EET 2026 | Dock is here, lets carry on
Sun Jan 11 15:48:08 EET 2026 | Starting downloading of [Microsoft Azure Storage Explorer]
Sun Jan 11 15:48:08 EET 2026 | Waiting for other [curl -f] processes to end
Sun Jan 11 15:48:08 EET 2026 | No instances of [curl -f] found, safe to proceed
Sun Jan 11 15:48:08 EET 2026 | Downloading Microsoft Azure Storage Explorer
Sun Jan 11 15:48:22 EET 2026 | Downloaded file detected as [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.njn5QBnliG/StorageExplorer-darwin-arm64.zip]
Sun Jan 11 15:48:22 EET 2026 | Detected install type as [ZIP]
Sun Jan 11 15:48:22 EET 2026 | Using installer file [/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.njn5QBnliG/StorageExplorer-darwin-arm64.zip]
Sun Jan 11 15:48:22 EET 2026 | Waiting for other [/Applications/Microsoft Azure Storage Explorer.app/Contents/MacOS/Electron] processes to end
Sun Jan 11 15:48:22 EET 2026 | No instances of [/Applications/Microsoft Azure Storage Explorer.app/Contents/MacOS/Electron] found, safe to proceed
Sun Jan 11 15:48:22 EET 2026 | Installing Microsoft Azure Storage Explorer
Sun Jan 11 15:48:22 EET 2026 | Changed current directory to /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.njn5QBnliG
Sun Jan 11 15:48:28 EET 2026 | /var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/tmp.njn5QBnliG/StorageExplorer-darwin-arm64.zip unzipped
Sun Jan 11 15:48:35 EET 2026 | Microsoft Azure Storage Explorer moved into /Applications
Sun Jan 11 15:48:36 EET 2026 | Determining logged-in user for ownership
Sun Jan 11 15:48:36 EET 2026 | Setting ownership of [/Applications/Microsoft Azure Storage Explorer.app] to [johndoe:admin]
Sun Jan 11 15:48:37 EET 2026 | Ownership and permissions successfully applied
drwxr-xr-x  3 johndoe  admin  96 Nov  1 02:22 /Applications/Microsoft Azure Storage Explorer.app
Sun Jan 11 15:48:37 EET 2026 | Microsoft Azure Storage Explorer Installed
Sun Jan 11 15:48:37 EET 2026 | Cleaning Up
Sun Jan 11 15:48:37 EET 2026 | Writing last modifieddate [Tue, 04 Nov 2025 01:08:44 GMT] to [/Library/Logs/Microsoft/IntuneScripts/installMicrosofAzureStorageExplorer/Microsoft Azure Storage Explorer.meta]
Sun Jan 11 15:48:37 EET 2026 | Application [Microsoft Azure Storage Explorer] successfully installed

```
