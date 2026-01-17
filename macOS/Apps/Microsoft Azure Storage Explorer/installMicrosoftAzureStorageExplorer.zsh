#!/bin/zsh
#set -x

############################################################################################
##
## Script to install the latest Microsoft Azure Storage Explorer
##
## VER 1.0.1
##
## Change Log
##
## 2026-01-11: Migrated script to zsh; removed Octory references
## 2026-01-11: Improved download artifact detection (zsh nullglob + newest-file selection)
## 2026-01-11: Set installed app ownership to console user:admin; permissions owner RW, group/others R (no write)
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
weburl="https://aka.ms/storageexplorer/downloadmacosarm64"                                  # Download URL
appname="Microsoft Azure Storage Explorer"                                                  # App name for logging
app="Microsoft Azure Storage Explorer.app"                                                  # Installed app bundle name
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installMicrosofAzureStorageExplorer"   # Logs + metadata
processpath="/Applications/Microsoft Azure Storage Explorer.app/Contents/MacOS/Electron"    # Process to check
terminateprocess="false"                                                                    # Terminate process if running?
autoUpdate="true"                                                                           # If true, exit if already installed
targetGroup="admin"                                                                         # Group ownership for installed application      
installedAppPath="/Applications/$app"                                                       # Final install path

# Generated variables
tempdir="$(mktemp -d)"  
log="$logandmetadir/$appname.log"
metafile="$logandmetadir/$appname.meta"

waitForProcess () {

    local processName="$1"
    local fixedDelay="$2"
    local terminate="$3"

    echo "$(date) | Waiting for other [$processName] processes to end"
    while ps aux | grep "$processName" | grep -v grep &>/dev/null; do

        if [[ "$terminate" == "true" ]]; then
            echo "$(date) | + [$appname] running, terminating [$processpath]..."
            pkill -f "$processName"
            return 0
        fi

        local delay=""
        if [[ -z "$fixedDelay" ]]; then
            delay=$(( RANDOM % 50 + 10 ))
        else
            delay="$fixedDelay"
        fi

        echo "$(date) |  + Another instance of $processName is running, waiting [$delay] seconds"
        sleep "$delay"
    done

    echo "$(date) | No instances of [$processName] found, safe to proceed"
}

checkForRosetta2 () {

    echo "$(date) | Checking if we need Rosetta 2 or not"

    # if Software update is already running, we need to wait...
    waitForProcess "/usr/sbin/softwareupdate"

    local OLDIFS="$IFS"
    IFS='.' read -r osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"
    IFS="$OLDIFS"

    if [[ ${osvers_major} -ge 11 ]]; then

        local processor
        processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Intel")

        if [[ -n "$processor" ]]; then
            echo "$(date) | $processor processor installed. No need to install Rosetta."
        else
            if /usr/bin/pgrep oahd >/dev/null 2>&1; then
                echo "$(date) | Rosetta is already installed and running. Nothing to do."
            else
                /usr/sbin/softwareupdate --install-rosetta --agree-to-license
                if [[ $? -eq 0 ]]; then
                    echo "$(date) | Rosetta has been successfully installed."
                else
                    echo "$(date) | Rosetta installation failed!"
                    exit 1
                fi
            fi
        fi
    else
        echo "$(date) | Mac is running macOS $osvers_major.$osvers_minor.$osvers_dot_version."
        echo "$(date) | No need to install Rosetta on this version of macOS."
    fi
}

fetchLastModifiedDate() {

    if [[ ! -d "$logandmetadir" ]]; then
        echo "$(date) | Creating [$logandmetadir] to store metadata"
        mkdir -p "$logandmetadir"
    fi

    lastmodified="$(curl -sIL "$weburl" | grep -i "last-modified" | awk '{$1=""; print $0}' | awk '{ sub(/^[ \t]+/, ""); print }' | tr -d '\r')"

    if [[ "$1" == "update" ]]; then
        echo "$(date) | Writing last modifieddate [$lastmodified] to [$metafile]"
        echo "$lastmodified" > "$metafile"
    fi
}

downloadApp () {

    echo "$(date) | Starting downloading of [$appname]"

    waitForProcess "curl -f"

    echo "$(date) | Downloading $appname"

    cd "$tempdir" || {
        echo "$(date) | ERROR: Failed to cd into [$tempdir]"
        exit 1
    }

    curl -f -s --connect-timeout 30 --retry 5 --retry-delay 60 -L -J -O "$weburl"
    if [[ $? -ne 0 ]]; then
        echo "$(date) | ERROR: Failure to download [$weburl]"
        exit 1
    fi

    # zsh-safe: capture actual downloaded files (null if none match)
    local files
    files=( "$tempdir"/*(N) )

    if (( ${#files} == 0 )); then
        echo "$(date) | ERROR: Download completed but no file found in [$tempdir]"
        echo "$(date) | Directory listing:"
        ls -la "$tempdir"
        exit 1
    fi

    # If multiple files exist, pick the newest (by mtime)
    files=( "$tempdir"/*(N.om) )
    tempfile="${files[-1]}"

    echo "$(date) | Downloaded file detected as [$tempfile]"

    case "$tempfile" in
        *.pkg|*.PKG) packageType="PKG" ;;
        *.zip|*.ZIP) packageType="ZIP" ;;
        *.dmg|*.DMG) packageType="DMG" ;;
        *)
            echo "$(date) | Unknown file extension, analysing metadata"
            local metadata
            metadata="$(file -b "$tempfile")"
            echo "$(date) | Metadata: $metadata"

            if [[ "$metadata" == *"Zip archive data"* ]]; then
                packageType="ZIP"
                mv -f "$tempfile" "$tempdir/install.zip"
                tempfile="$tempdir/install.zip"
            elif [[ "$metadata" == *"xar archive"* ]]; then
                packageType="PKG"
                mv -f "$tempfile" "$tempdir/install.pkg"
                tempfile="$tempdir/install.pkg"
            elif [[ "$metadata" == *"bzip2 compressed data"* || "$metadata" == *"zlib compressed data"* || "$metadata" == *"Apple disk image"* ]]; then
                packageType="DMG"
                mv -f "$tempfile" "$tempdir/install.dmg"
                tempfile="$tempdir/install.dmg"
            fi
        ;;
    esac

    if [[ -z "$packageType" ]]; then
        echo "$(date) | ERROR: Failed to determine downloaded file type for [$tempfile]"
        echo "$(date) | Directory listing:"
        ls -la "$tempdir"
        exit 1
    fi

    echo "$(date) | Detected install type as [$packageType]"
    echo "$(date) | Using installer file [$tempfile]"
}

updateCheck() {

    echo "$(date) | Checking if we need to install or update [$appname]"

    if [[ -d "/Applications/$app" ]]; then
        if [[ "$autoUpdate" == "true" ]]; then
            echo "$(date) | [$appname] is already installed and handles updates itself, exiting"
            exit 0
        fi

        echo "$(date) | [$appname] already installed, let's see if we need to update"
        fetchLastModifiedDate

        if [[ -d "$logandmetadir" && -f "$metafile" ]]; then
            previouslastmodifieddate="$(cat "$metafile")"
            if [[ "$previouslastmodifieddate" != "$lastmodified" ]]; then
                echo "$(date) | Update found, previous [$previouslastmodifieddate] and current [$lastmodified]"
                update="update"
            else
                echo "$(date) | No update between previous [$previouslastmodifieddate] and current [$lastmodified]"
                echo "$(date) | Exiting, nothing to do"
                exit 0
            fi
        else
            echo "$(date) | Meta file [$metafile] not found"
            echo "$(date) | Unable to determine if update required, updating [$appname] anyway"
        fi
    else
        echo "$(date) | [$appname] not installed, need to download and install"
    fi
}

fixPermissions () {

    echo "$(date) | Determining logged-in user for ownership"

    local targetUser
    targetUser="$(/usr/bin/stat -f%Su /dev/console)"

    if [[ -z "$targetUser" || "$targetUser" == "root" || "$targetUser" == "_mbsetupuser" ]]; then
        echo "$(date) | WARNING: No valid logged-in user detected. Skipping permission changes."
        return 0
    fi

    echo "$(date) | Setting ownership of [$installedAppPath] to [$targetUser:$targetGroup]"

    if [[ ! -d "$installedAppPath" ]]; then
        echo "$(date) | ERROR: App path [$installedAppPath] not found."
        exit 1
    fi

    if ! id "$targetUser" &>/dev/null; then
        echo "$(date) | ERROR: User [$targetUser] does not exist on this Mac."
        exit 1
    fi

    chown -R "$targetUser:$targetGroup" "$installedAppPath" || {
        echo "$(date) | ERROR: Failed to chown [$installedAppPath]"
        exit 1
    }

    chmod -R u+rwX,go+rX,go-w "$installedAppPath" || {
        echo "$(date) | ERROR: Failed to chmod [$installedAppPath]"
        exit 1
    }

    echo "$(date) | Ownership and permissions successfully applied"
    ls -ld "$installedAppPath"
}

installPKG () {

    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(date) | Installing $appname"

    if [[ -d "/Applications/$app" ]]; then
        rm -rf "/Applications/$app"
    fi

    installer -pkg "$tempfile" -target /Applications

    if [[ "$?" -eq 0 ]]; then
        echo "$(date) | $appname Installed"
        echo "$(date) | Cleaning Up"
        rm -rf "$tempdir"

        fixPermissions

        echo "$(date) | Application [$appname] successfully installed"
        fetchLastModifiedDate update
        exit 0
    else
        echo "$(date) | Failed to install $appname"
        rm -rf "$tempdir"
        exit 1
    fi
}

installDMG () {

    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(date) | Installing [$appname]"

    volume="$tempdir/$appname"
    echo "$(date) | Mounting Image"
    hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$tempfile"

    if [[ -d "/Applications/$app" ]]; then
        echo "$(date) | Removing existing files"
        rm -rf "/Applications/$app"
    fi

    echo "$(date) | Copying app files to /Applications/$app"
    rsync -a "$volume"/*.app/ "/Applications/$app"

    echo "$(date) | Un-mounting [$volume]"
    hdiutil detach -quiet "$volume"

    if [[ -d "/Applications/$app" ]]; then
        echo "$(date) | [$appname] Installed"
        echo "$(date) | Cleaning Up"
        rm -rf "$tempfile"

        fixPermissions

        echo "$(date) | Application [$appname] successfully installed"
        fetchLastModifiedDate update
        exit 0
    else
        echo "$(date) | Failed to install [$appname]"
        rm -rf "$tempdir"
        exit 1
    fi
}

installZIP () {

    waitForProcess "$processpath" "300" "$terminateprocess"

    echo "$(date) | Installing $appname"

    cd "$tempdir" || {
        echo "$(date) | failed to change to $tempdir"
        [[ -d "$tempdir" ]] && rm -rf "$tempdir"
        exit 1
    }
    echo "$(date) | Changed current directory to $tempdir"

    unzip -qq -o "$tempfile"
    if [[ "$?" -ne 0 ]]; then
        echo "$(date) | failed to unzip $tempfile"
        [[ -d "$tempdir" ]] && rm -rf "$tempdir"
        exit 1
    fi
    echo "$(date) | $tempfile unzipped"

    if [[ -d "/Applications/$app" ]]; then
        echo "$(date) | Removing old installation at /Applications/$app"
        rm -rf "/Applications/$app"
    fi

    rsync -a "$app/" "/Applications/$app"
    if [[ "$?" -ne 0 ]]; then
        echo "$(date) | failed to move $appname to /Applications"
        [[ -d "$tempdir" ]] && rm -rf "$tempdir"
        exit 1
    fi
    echo "$(date) | $appname moved into /Applications"

    fixPermissions

    if [[ -d "/Applications/$app" ]]; then
        echo "$(date) | $appname Installed"
        echo "$(date) | Cleaning Up"
        rm -rf "$tempfile"

        fetchLastModifiedDate update

        echo "$(date) | Application [$appname] successfully installed"
        exit 0
    else
        echo "$(date) | Failed to install $appname"
        [[ -d "$tempdir" ]] && rm -rf "$tempdir"
        exit 1
    fi
}

startLog() {

    if [[ ! -d "$logandmetadir" ]]; then
        echo "$(date) | Creating [$logandmetadir] to store logs"
        mkdir -p "$logandmetadir"
    fi

    exec > >(tee -a "$log") 2>&1
}

waitForDesktop () {
  until ps aux | grep "/System/Library/CoreServices/Dock.app/Contents/MacOS/Dock" | grep -v grep &>/dev/null; do
    local delay=$(( RANDOM % 50 + 10 ))
    echo "$(date) |  + Dock not running, waiting [$delay] seconds"
    sleep "$delay"
  done
  echo "$(date) | Dock is here, lets carry on"
}

###################################################################################
##
## Begin Script Body
##
###################################################################################

startLog

echo ""
echo "##############################################################"
echo "# $(date) | Logging install of [$appname] to [$log]"
echo "##############################################################"
echo ""

checkForRosetta2
updateCheck
waitForDesktop
downloadApp

if [[ "$packageType" == "PKG" ]]; then
    installPKG
fi

if [[ "$packageType" == "ZIP" ]]; then
    installZIP
fi

if [[ "$packageType" == "DMG" ]]; then
    installDMG
fi