#!/bin/zsh
#set -x
############################################################################################
##
## Script to set and enforce KeePassXC settings on macOS (User Level)
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
appname="KeePassXCPolicyEnforcerUserLevel"                              # The name of our script
configdir="$HOME/Library/Application Support/KeePassXC"                 # Location of KeePassXC configuration directory
default_ini_name="KeePassXC.ini"                                        # Used only when no existing config file is found
ini="$configdir/$default_ini_name"                                      # Updated at runtime to preserve an existing filename exactly
logandmetadir="$HOME/Library/Logs/Microsoft/IntuneScripts/$appname"     # The location of our logs and last updated data
log="$logandmetadir/$appname.log"                                       # The location of the script log file

# ============================================================
# KeePassXC managed settings
# ============================================================
#
# QUICK GUIDE
# -----------
# 1. Add one setting per line using the format:
#        'Key=Value'
#
# 2. To enforce an empty value, leave everything after "=" empty:
#        'CustomProxyLocation='
#
# 3. Leave a section array empty to make that section unmanaged:
#        typeset -a SSHAGENT_SETTINGS=(
#        )
#    An unmanaged section is left unchanged and the script reports [SKIP].
#
# 4. Only keys listed below are enforced. Other existing keys in the same
#    INI section are preserved and are not removed or changed.
#
# 5. If a listed key does not exist, it is added. If it exists with a
#    different value, it is updated. If it is already correct, [OK] is logged.
#
# 6. Values may contain additional "=" characters. The first "=" separates
#    the key from the value.
#
# 7. Prefer single quotes around each Key=Value entry. This keeps characters
#    such as $, \\, double quotes, and braces literal in the policy definition.
#
# 8. The existing KeePassXC INI filename is preserved exactly, including its
#    capitalization (for example, KeepassXC.ini stays KeepassXC.ini). If no
#    matching file exists, the script creates the default name KeePassXC.ini.
#
# 9. The script normalizes section spacing so there is exactly one blank line
#    between INI sections. No extra blank line is added after the final section.
#
# IMPORTANT: Do not place generated secrets/private keys in this script.
# For example, KeeShare "Own=" contains key material. Leaving that key out of
# KEESHARE_SETTINGS means the existing value in KeePassXC.ini is preserved.
# ============================================================

# [General]
# Empty array = unmanaged section.
typeset -a GENERAL_SETTINGS=(
    'UpdateCheckMessageShown=true'
)

# [Browser]
# Empty array = unmanaged section.
typeset -a BROWSER_SETTINGS=(
)

# [GUI]
# Empty array = unmanaged section.
typeset -a GUI_SETTINGS=(
    'Language=en_US'
    'ColorPasswords=true'
    'CheckForUpdates=false'
)

# [KeeShare]
# Empty array = unmanaged section.
typeset -a KEESHARE_SETTINGS=(
)

# [PasswordGenerator]
# Empty array = unmanaged section.
typeset -a PASSWORDGENERATOR_SETTINGS=(
)

# [SSHAgent]
# Empty array = unmanaged section.
typeset -a SSHAGENT_SETTINGS=(
)

# [Security]
# Empty array = unmanaged section.
typeset -a SECURITY_SETTINGS=(
)

# Create log directory if it doesn't exist
if [ -d "$logandmetadir" ]; then
    echo "$(/bin/date) | Log directory already exists - $logandmetadir"
else
    echo "$(/bin/date) | Creating log directory - $logandmetadir"
    mkdir -p "$logandmetadir"
fi

# Ensure the KeePassXC configuration directory and INI file exist.
# If an existing keepassxc.ini is found, use its exact filename/capitalization.
ensure_ini_exists() {
    local existing_ini

    if [[ ! -d "$configdir" ]]; then
        echo "$(/bin/date) | [CREATE] Creating directory: $configdir"
        /bin/mkdir -p "$configdir" || return 1
    fi

    existing_ini="$(/usr/bin/find "$configdir" -maxdepth 1 -type f -iname 'keepassxc.ini' -print -quit 2>/dev/null)"

    if [[ -n "$existing_ini" ]]; then
        ini="$existing_ini"
        echo "$(/bin/date) | [OK] Using existing KeePassXC configuration without changing filename: $ini"
        return 0
    fi

    ini="$configdir/$default_ini_name"
    echo "$(/bin/date) | [CREATE] Creating KeePassXC configuration: $ini"
    /usr/bin/touch "$ini" || return 1
    /bin/chmod 644 "$ini" 2>/dev/null
}

# Read the first value for an exact key within an exact INI section
get_ini_value() {
    local section="$1"
    local key="$2"

    /usr/bin/awk -v target_section="$section" -v target_key="$key" '
        function trim(s) {
            sub(/^[[:space:]]+/, "", s)
            sub(/[[:space:]]+$/, "", s)
            return s
        }

        /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
            current = $0
            sub(/^[[:space:]]*\[/, "", current)
            sub(/\][[:space:]]*$/, "", current)
            in_section = (current == target_section)
            next
        }

        in_section {
            line = $0
            stripped = line
            sub(/^[[:space:]]+/, "", stripped)
            if (stripped ~ /^[#;]/ || index(line, "=") == 0) {
                next
            }

            lhs = substr(line, 1, index(line, "=") - 1)
            lhs = trim(lhs)
            if (lhs == target_key) {
                value = substr(line, index(line, "=") + 1)
                print value
                exit
            }
        }
    ' "$ini"
}

# Return success when an exact key exists within an exact INI section
ini_key_exists() {
    local section="$1"
    local key="$2"

    /usr/bin/awk -v target_section="$section" -v target_key="$key" '
        function trim(s) {
            sub(/^[[:space:]]+/, "", s)
            sub(/[[:space:]]+$/, "", s)
            return s
        }

        /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
            current = $0
            sub(/^[[:space:]]*\[/, "", current)
            sub(/\][[:space:]]*$/, "", current)
            in_section = (current == target_section)
            next
        }

        in_section {
            line = $0
            stripped = line
            sub(/^[[:space:]]+/, "", stripped)
            if (stripped ~ /^[#;]/ || index(line, "=") == 0) {
                next
            }

            lhs = substr(line, 1, index(line, "=") - 1)
            lhs = trim(lhs)
            if (lhs == target_key) {
                found = 1
                exit
            }
        }

        END { exit(found ? 0 : 1) }
    ' "$ini"
}

# Atomically set one INI value while preserving other sections, keys, comments, and KeeShare data
set_ini_value() {
    local section="$1"
    local key="$2"
    local expected="$3"
    local current
    local tmp

    if ini_key_exists "$section" "$key"; then
        current="$(get_ini_value "$section" "$key")"
        if [[ "$current" == "$expected" ]]; then
            echo "$(/bin/date) | [OK] [$section] $key is already set to '$expected'"
            return 0
        fi
        echo "$(/bin/date) | [UPDATE] [$section] $key: '$current' -> '$expected'"
    else
        current=""
        echo "$(/bin/date) | [ADD] [$section] $key = '$expected'"
    fi

    tmp="$(/usr/bin/mktemp "${ini}.tmp.XXXXXX")" || {
        echo "$(/bin/date) | [ERROR] Could not create temporary file for $ini"
        return 1
    }

    /usr/bin/awk -v target_section="$section" -v target_key="$key" -v expected="$expected" '
        function trim(s) {
            sub(/^[[:space:]]+/, "", s)
            sub(/[[:space:]]+$/, "", s)
            return s
        }

        # Blank lines at the end of the target section are held back so a
        # newly-added key is written before them, not after them. This keeps
        # the blank line as a clean separator between INI sections.
        function flush_pending_blanks(    i) {
            for (i = 0; i < pending_blanks; i++) {
                print ""
            }
            pending_blanks = 0
        }

        function write_key_if_needed() {
            if (in_section && !key_written) {
                print target_key "=" expected
                key_written = 1
            }
        }

        /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
            if (in_section) {
                write_key_if_needed()
                flush_pending_blanks()
            }

            current = $0
            sub(/^[[:space:]]*\[/, "", current)
            sub(/\][[:space:]]*$/, "", current)

            in_section = (current == target_section)
            if (in_section) {
                section_found = 1
                key_written = 0
                pending_blanks = 0
            }

            print
            next
        }

        in_section {
            # Buffer blank lines while inside the target section. If another
            # normal line follows, they were internal blanks and are restored.
            # If the next line is a section header (or EOF), a missing key is
            # inserted first and the buffered blanks remain after the key.
            if ($0 ~ /^[[:space:]]*$/) {
                pending_blanks++
                next
            }

            flush_pending_blanks()

            line = $0
            stripped = line
            sub(/^[[:space:]]+/, "", stripped)

            if (stripped !~ /^[#;]/ && index(line, "=") > 0) {
                lhs = substr(line, 1, index(line, "=") - 1)
                lhs = trim(lhs)

                if (lhs == target_key) {
                    if (!key_written) {
                        print target_key "=" expected
                        key_written = 1
                    }
                    next
                }
            }
        }

        { print }

        END {
            if (in_section) {
                write_key_if_needed()
                flush_pending_blanks()
            }

            if (!section_found) {
                if (NR > 0) {
                    print ""
                }
                print "[" target_section "]"
                print target_key "=" expected
            }
        }
    ' "$ini" > "$tmp"

    if [[ $? -ne 0 ]]; then
        echo "$(/bin/date) | [ERROR] Failed to update [$section] $key"
        /bin/rm -f "$tmp"
        return 1
    fi

    # KeePassXC.ini must always have mode 644
    /bin/chmod 644 "$tmp" || {
        echo "$(/bin/date) | [ERROR] Failed to set permissions 644 on temporary file"
        /bin/rm -f "$tmp"
        return 1
    }

    /bin/mv -f "$tmp" "$ini" || {
        echo "$(/bin/date) | [ERROR] Failed to replace $ini"
        /bin/rm -f "$tmp"
        return 1
    }
}

# Normalize INI section spacing without changing keys or values.
# Exactly one blank line is kept between section blocks. Trailing blank lines
# after the final section are removed; the file still ends with a normal newline.
# This runs even when every managed value was already correct, so formatting
# is always enforced.
normalize_ini_section_spacing() {
    local tmp

    tmp="$(/usr/bin/mktemp "${ini}.spacing.XXXXXX")" || {
        echo "$(/bin/date) | [ERROR] Could not create temporary file for INI spacing normalization"
        return 1
    }

    /usr/bin/awk '
        function flush_pending_blanks(    i) {
            for (i = 0; i < pending_blanks; i++) {
                print ""
            }
            pending_blanks = 0
        }

        /^[[:space:]]*$/ {
            pending_blanks++
            next
        }

        /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
            if (seen_section) {
                # Replace any number of trailing blank lines from the previous
                # section with exactly one separator line.
                pending_blanks = 0
                print ""
            } else {
                # Preserve any leading blank lines before the first section.
                flush_pending_blanks()
            }

            print
            seen_section = 1
            next
        }

        {
            # Blank lines that are not directly before a new section are
            # internal content and are preserved as-is.
            flush_pending_blanks()
            print
        }

        END {
            if (seen_section) {
                # Discard blank lines after the final section. The last normal
                # print already gives the file its terminating newline.
                pending_blanks = 0
            } else {
                flush_pending_blanks()
            }
        }
    ' "$ini" > "$tmp"

    if [[ $? -ne 0 ]]; then
        echo "$(/bin/date) | [ERROR] Failed to normalize INI section spacing"
        /bin/rm -f "$tmp"
        return 1
    fi

    /bin/chmod 644 "$tmp" || {
        echo "$(/bin/date) | [ERROR] Failed to set permissions 644 on spacing temporary file"
        /bin/rm -f "$tmp"
        return 1
    }

    /bin/mv -f "$tmp" "$ini" || {
        echo "$(/bin/date) | [ERROR] Failed to replace $ini after spacing normalization"
        /bin/rm -f "$tmp"
        return 1
    }

    echo "$(/bin/date) | [OK] INI section spacing normalized"
}

# Apply all configured Key=Value settings for one INI section.
# If the settings array is empty, the section is reported as unmanaged.
apply_ini_section() {
    local section="$1"
    shift

    local -a settings=("$@")
    local setting
    local key
    local value

    if (( ${#settings[@]} == 0 )); then
        echo "$(/bin/date) | [SKIP] [$section] No managed settings configured; section left unchanged"
        return 0
    fi

    for setting in "${settings[@]}"; do
        if [[ "$setting" != *=* ]]; then
            echo "$(/bin/date) | [ERROR] [$section] Invalid policy entry '$setting' (expected Key=Value)"
            return 1
        fi

        key="${setting%%=*}"
        value="${setting#*=}"

        if [[ -z "$key" ]]; then
            echo "$(/bin/date) | [ERROR] [$section] Invalid policy entry '$setting' (key is empty)"
            return 1
        fi

        set_ini_value "$section" "$key" "$value" || return 1
    done
}

# Start logging
exec &> >(tee -a "$log")

# Begin Script Body
echo ""
echo "##############################################################"
echo "# $(/bin/date) | Starting running of script $appname"
echo "##############################################################"
echo ""

# Run functions

# Make sure all parent dictionaries exist for a given key path in a plist
ensure_ini_exists || {
    echo "$(/bin/date) | [ERROR] Could not prepare KeePassXC configuration."
    exit 1
}

# Enforce required permissions even when all INI values are already correct
current_mode="$(/usr/bin/stat -f '%Lp' "$ini" 2>/dev/null)"
if [[ "$current_mode" != "644" ]]; then
    echo "$(/bin/date) | [PERMISSIONS] $ini: ${current_mode:-unknown} -> 644"
    /bin/chmod 644 "$ini" || {
        echo "$(/bin/date) | [ERROR] Failed to set permissions 644 on $ini"
        exit 1
    }
else
    echo "$(/bin/date) | [OK] File permissions are already 644"
fi

# Enforce values from the supplied KeePassXC configuration

# Apply every supported section. Empty arrays are automatically reported as unmanaged.
apply_ini_section "General" "${GENERAL_SETTINGS[@]}" || exit 1
apply_ini_section "Browser" "${BROWSER_SETTINGS[@]}" || exit 1
apply_ini_section "GUI" "${GUI_SETTINGS[@]}" || exit 1
apply_ini_section "KeeShare" "${KEESHARE_SETTINGS[@]}" || exit 1
apply_ini_section "PasswordGenerator" "${PASSWORDGENERATOR_SETTINGS[@]}" || exit 1
apply_ini_section "SSHAgent" "${SSHAGENT_SETTINGS[@]}" || exit 1
apply_ini_section "Security" "${SECURITY_SETTINGS[@]}" || exit 1

# Always enforce clean section spacing, even if no managed value changed.
normalize_ini_section_spacing || exit 1

# End of script
echo ""
echo "$(/bin/date) | Script $appname completed."
echo "##############################################################"