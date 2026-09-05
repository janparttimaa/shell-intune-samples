#!/bin/zsh
#set -x

############################################################################################
##
## Extension Attribute script to return user's macOS language and locale settings
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

# Get the username of the currently logged-in console user
CURRENT_USER=$(/usr/bin/stat -f "%Su" /dev/console)

# Handle cases where no regular user is logged in
if [[ -z "$CURRENT_USER" || "$CURRENT_USER" == "root" || "$CURRENT_USER" == "loginwindow" ]]; then
    echo "Username=none | Language=unknown | Locale=unknown"
    exit 0
fi

# Get the UID of the logged-in user
USER_UID=$(/usr/bin/id -u "$CURRENT_USER")

# Read the user's primary macOS language
LANGUAGE=$(
    /bin/launchctl asuser "$USER_UID" \
    /usr/bin/sudo -u "$CURRENT_USER" \
    /usr/bin/defaults read NSGlobalDomain AppleLanguages 2>/dev/null |
    /usr/bin/grep -o '"[^"]*"' |
    /usr/bin/head -1 |
    /usr/bin/tr -d '"'
)

# Read the user's configured macOS locale
LOCALE=$(
    /bin/launchctl asuser "$USER_UID" \
    /usr/bin/sudo -u "$CURRENT_USER" \
    /usr/bin/defaults read NSGlobalDomain AppleLocale 2>/dev/null
)

# Return a single-line result with separators
echo "Username=$CURRENT_USER | Language=${LANGUAGE:-unknown} | Locale=${LOCALE:-unknown}"