#!/bin/zsh
#set -x
############################################################################################
##
## Script to set macOS language and locale settings
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
appname="SetLanguageAndLocaleSettings"                              # The name of our script
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/$appname"      # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                   # The location of the script log file
targetlanguage="en-US"                                              # The target language to set in BCP 47 format (e.g., en-US, fr-FR, es-ES, etc.)
targetlocale="fi_FI"                                                # The target locale to set in Apple/POSIX-style locale notation (e.g., en_US, fr_FR, es_ES, etc.)  
systempreferencesdomain="/Library/Preferences/.GlobalPreferences"   # The domain for system-level preferences
abmcheck=true                                                       # Run this script if this device is ABM managed

# Machine-level changes require root. Microsoft Intune runs scripts as root.
if [[ "$EUID" -ne 0 ]]; then
    echo "$(date) | ERROR: This script must run as root."
    exit 1
fi

# Check if the log directory has been created
if [ -d "$logandmetadir" ]; then
    # Already created
    echo "$(date) | Log directory already exists - $logandmetadir"
else
    # Creating Metadirectory
    echo "$(date) | Creating log directory - $logandmetadir"
    mkdir -p "$logandmetadir"
fi

# Return the first language from an AppleLanguages array.
ReadPrimaryLanguage() {
    /usr/bin/defaults read "$1" AppleLanguages 2>/dev/null |
    /usr/bin/grep -o '"[^"]*"' |
    /usr/bin/head -1 |
    /usr/bin/tr -d '"'
}

# Configure the machine-level preferences used by the login window.
SetSystemLanguageAndLocale() {

    echo "$(date) | Checking system/login-window language and locale..."

    currentsystemlanguage=$(ReadPrimaryLanguage "$systempreferencesdomain")
    currentsystemlocale=$(/usr/bin/defaults read "$systempreferencesdomain" AppleLocale 2>/dev/null)

    echo "$(date) | Current system language: ${currentsystemlanguage:-Not configured}"
    echo "$(date) | Required system language: $targetlanguage"
    echo "$(date) | Current system locale: ${currentsystemlocale:-Not configured}"
    echo "$(date) | Required system locale: $targetlocale"

    systemsettingschanged="false"

    if [[ "$currentsystemlanguage" != "$targetlanguage" ]]; then
        echo "$(date) | System language does not match required configuration."
        echo "$(date) | Setting system language to $targetlanguage..."

        if /usr/bin/defaults write "$systempreferencesdomain" AppleLanguages -array "$targetlanguage"; then
            echo "$(date) | System language successfully changed to $targetlanguage."
            systemsettingschanged="true"
        else
            echo "$(date) | ERROR: Failed to change system language."
            return 1
        fi
    else
        echo "$(date) | System language is already set correctly."
    fi

    if [[ "$currentsystemlocale" != "$targetlocale" ]]; then
        echo "$(date) | System locale does not match required configuration."
        echo "$(date) | Setting system locale to $targetlocale..."

        if /usr/bin/defaults write "$systempreferencesdomain" AppleLocale -string "$targetlocale"; then
            echo "$(date) | System locale successfully changed to $targetlocale."
            systemsettingschanged="true"
        else
            echo "$(date) | ERROR: Failed to change system locale."
            return 1
        fi
    else
        echo "$(date) | System locale is already set correctly."
    fi

    if [[ "$systemsettingschanged" == "true" ]]; then
        echo "$(date) | Restarting the root preference daemon..."
        /usr/bin/killall -u root cfprefsd 2>/dev/null || true
        /bin/sleep 2
    fi

    finalsystemlanguage=$(ReadPrimaryLanguage "$systempreferencesdomain")
    finalsystemlocale=$(/usr/bin/defaults read "$systempreferencesdomain" AppleLocale 2>/dev/null)

    echo "$(date) | Final system language: ${finalsystemlanguage:-Not configured}"
    echo "$(date) | Final system locale: ${finalsystemlocale:-Not configured}"

    if [[ "$finalsystemlanguage" == "$targetlanguage" && "$finalsystemlocale" == "$targetlocale" ]]; then
        echo "$(date) | System/login-window language and locale are configured correctly."
        return 0
    fi

    echo "$(date) | ERROR: System/login-window configuration verification failed."
    return 1
}

# Configure preferences for the currently logged-in user, when one exists.
SetUserLanguageAndLocale() {

    # Get currently logged-in user
    loggedinuser=$(/usr/bin/stat -f "%Su" /dev/console)

    # Check that a normal user is logged in
    if [[ -z "$loggedinuser" || "$loggedinuser" == "root" || "$loggedinuser" == "loginwindow" ]]; then
        echo "$(date) | No logged-in user detected. Skipping user-level configuration."
        return 0
    fi

    loggedinuseruid=$(/usr/bin/id -u "$loggedinuser")

    echo "$(date) | Logged-in user: $loggedinuser"
    echo "$(date) | Logged-in user UID: $loggedinuseruid"

    # Read current primary language
    currentlanguage=$(
        /bin/launchctl asuser "$loggedinuseruid" \
        /usr/bin/sudo -u "$loggedinuser" \
        /usr/bin/defaults read NSGlobalDomain AppleLanguages 2>/dev/null |
        /usr/bin/grep -o '"[^"]*"' |
        /usr/bin/head -1 |
        /usr/bin/tr -d '"'
    )

    # Read current locale
    currentlocale=$(
        /bin/launchctl asuser "$loggedinuseruid" \
        /usr/bin/sudo -u "$loggedinuser" \
        /usr/bin/defaults read NSGlobalDomain AppleLocale 2>/dev/null
    )

    echo "$(date) | Current language: ${currentlanguage:-Not configured}"
    echo "$(date) | Required language: $targetlanguage"
    echo "$(date) | Current locale: ${currentlocale:-Not configured}"
    echo "$(date) | Required locale: $targetlocale"

    settingschanged="false"

    # Check language
    if [[ "$currentlanguage" != "$targetlanguage" ]]; then

        echo "$(date) | Language does not match required configuration."
        echo "$(date) | Setting language to $targetlanguage..."

        /bin/launchctl asuser "$loggedinuseruid" \
        /usr/bin/sudo -u "$loggedinuser" \
        /usr/bin/defaults write NSGlobalDomain AppleLanguages -array "$targetlanguage"

        if [[ $? -eq 0 ]]; then
            echo "$(date) | Language successfully changed to $targetlanguage."
            settingschanged="true"
        else
            echo "$(date) | ERROR: Failed to change language."
            return 1
        fi

    else
        echo "$(date) | Language is already set correctly."
    fi

    # Check locale
    if [[ "$currentlocale" != "$targetlocale" ]]; then

        echo "$(date) | Locale does not match required configuration."
        echo "$(date) | Setting locale to $targetlocale..."

        /bin/launchctl asuser "$loggedinuseruid" \
        /usr/bin/sudo -u "$loggedinuser" \
        /usr/bin/defaults write NSGlobalDomain AppleLocale -string "$targetlocale"

        if [[ $? -eq 0 ]]; then
            echo "$(date) | Locale successfully changed to $targetlocale."
            settingschanged="true"
        else
            echo "$(date) | ERROR: Failed to change locale."
            return 1
        fi

    else
        echo "$(date) | Locale is already set correctly."
    fi

    # Refresh preferences
    if [[ "$settingschanged" == "true" ]]; then
        echo "$(date) | Restarting preference daemon for $loggedinuser..."

        /bin/launchctl asuser "$loggedinuseruid" \
        /usr/bin/sudo -u "$loggedinuser" \
        /usr/bin/killall cfprefsd 2>/dev/null

        /bin/sleep 2
    fi

    # Verify configuration
    finallanguage=$(
        /bin/launchctl asuser "$loggedinuseruid" \
        /usr/bin/sudo -u "$loggedinuser" \
        /usr/bin/defaults read NSGlobalDomain AppleLanguages 2>/dev/null |
        /usr/bin/grep -o '"[^"]*"' |
        /usr/bin/head -1 |
        /usr/bin/tr -d '"'
    )

    finallocale=$(
        /bin/launchctl asuser "$loggedinuseruid" \
        /usr/bin/sudo -u "$loggedinuser" \
        /usr/bin/defaults read NSGlobalDomain AppleLocale 2>/dev/null
    )

    echo "$(date) | Final language: $finallanguage"
    echo "$(date) | Final locale: $finallocale"

    if [[ "$finallanguage" == "$targetlanguage" && "$finallocale" == "$targetlocale" ]]; then
        echo "$(date) | User language and locale are configured correctly."
        return 0
    fi

    echo "$(date) | ERROR: User language or locale configuration verification failed."
    return 1
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(date) | Starting running of script $appname"
echo "##############################################################"
echo ""

# Run functions

# Is this a ABM DEP device?
if [ "$abmcheck" = true ]; then
  echo "$(date) | Checking MDM Profile Type"
  profiles status -type enrollment | grep "Enrolled via DEP: Yes"
  if [[ ! $? == 0 ]]; then
    echo "$(date) | This device is not ABM managed"
    exit 0;
  else
    echo "$(date) | Device is ABM Managed"
  fi
fi

# Configure and verify both scopes. Attempt the user scope even if the
# system/login-window scope fails so the log contains the complete result.
overallstatus=0

SetSystemLanguageAndLocale || overallstatus=1
SetUserLanguageAndLocale || overallstatus=1

if [[ "$overallstatus" -eq 0 ]]; then
    echo "$(date) | All applicable language and locale settings are configured correctly. Closing script..."
else
    echo "$(date) | ERROR: One or more language or locale settings failed verification."
fi

exit "$overallstatus"