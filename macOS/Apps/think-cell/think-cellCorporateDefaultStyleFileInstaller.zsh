#!/bin/zsh
#set -x
############################################################################################
##
## Script to install the latest corporate default style file to think-cell
##
############################################################################################

## Copyright (c) 2026 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

# Define variables
weburl="https://catlab.blob.core.windows.net/apps/think-cell/Styles/Corporate%20style.xml?sp=r&st=2022-08-25T12:37:30Z&se=2099-08-25T20:37:30Z&spr=https&sv=2021-06-08&sr=b&sig=4HnMlm3dA9dJICxnpadFGNXZE8RuyRDCdXyMb1Xt9G0%3D"                                                     # What is the Azure Blob Storage URL?
appname="think-cellCorporateDefaultStyleFileInstaller"                                                  # The name of our file deployment script
file="Corporate style.xml"                                                                              # The actual name of our file once installed
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"                                          # The location of our logs and last updated data
folderpath="/Library/Application Support/Microsoft/think-cell/styles"                                   # The folder location where we will install the file
thinkcellinstallationpath="/Library/Application Support/Microsoft/think-cell/"                          # The folder location where think-cell is installed
filepath="$folderpath/$file"                                                                            # Complete Final location where file should and will be located
log="$logandmetadir/$appname.log"                                                                       # The location of the script log file

# Check if the log directory has been created
if [ -d "$logandmetadir" ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | creating log directory - $logandmetadir"
    mkdir -p "$logandmetadir"
fi

# Start logging
exec &> >(tee -a "$log")

# Check if think-cell is already installed
CheckIfThinkcellIsInstalled() {
if [ -d "$thinkcellinstallationpath" ]; then
    echo "$(date) | think-cell is installed. Let's proceed..."
else
    echo "$(date) | think-cell is not installed. No need to install corporate default style file. Closing the script..."
    exit 0
fi
}

# Verify that corporate default file is installed successfully
VerifyFile() {
if [ -f "$filepath" ]; then
    echo "$(date) | Corporate default style file to think-cell has been installed sucessfully. Closing script..."
    exit 0
else
    echo "$(date) | ERROR: Corporate default style file to think-cell has not be installed. Please contact to System Administrator in order to investigate the issue. Closing script..."
    exit 1
fi
}

# NEW: Get remote Last-Modified header as epoch seconds (empty if not available/parsable)
GetRemoteLastModifiedEpoch() {
    local last_modified remote_epoch

    last_modified=$(curl -sIL "$weburl" \
        | awk -F': ' 'tolower($1)=="last-modified"{print $2}' \
        | tail -n 1 \
        | tr -d '\r')

    if [ -z "$last_modified" ]; then
        echo ""
        return 0
    fi

    remote_epoch=$(date -j -f "%a, %d %b %Y %H:%M:%S %Z" "$last_modified" "+%s" 2>/dev/null)
    echo "$remote_epoch"
}

# Check if corporate default style file is already installed
CheckIfCorporateDefaultSyleFileIsInstalled() {

    # Ensure target folder exists (needed for both install/update paths)
    if [ -d "$folderpath" ]; then
        echo "$(date) | Styles folder already exists - $folderpath"
    else
        echo "$(date) | Styles folder does not exist - creating $folderpath"
        mkdir -p "$folderpath"
    fi

    if [ -f "$filepath" ]; then
        echo "$(date) | Corporate default style file is already installed. Checking if update is needed..."

        local local_epoch remote_epoch
        local_epoch=$(stat -f "%m" "$filepath" 2>/dev/null)
        remote_epoch=$(GetRemoteLastModifiedEpoch)

        # If we cannot compare reliably, treat as "not the same" and replace to ensure latest
        if [ -z "$local_epoch" ] || [ -z "$remote_epoch" ]; then
            echo "$(date) | WARNING: Could not reliably compare modified times (local: '$local_epoch', remote: '$remote_epoch'). Replacing file to ensure latest..."
            curl -L -f -o "$filepath" "$weburl"
            VerifyFile
        fi

        if [ "$local_epoch" -ne "$remote_epoch" ]; then
            echo "$(date) | File is outdated (local mtime: $local_epoch, remote: $remote_epoch). Replacing with newest..."
            curl -L -f -o "$filepath" "$weburl"
            VerifyFile
        else
            echo "$(date) | Corporate default style file is up to date. No action needed. Closing script..."
            exit 0
        fi
    else
        echo "$(date) | Corporate default style file to think-cell has not be installed. Let's proceed..."
        curl -L -f -o "$filepath" "$weburl"
        VerifyFile
    fi
}

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "############################################################"
echo ""

# Run function
CheckIfThinkcellIsInstalled
CheckIfCorporateDefaultSyleFileIsInstalled