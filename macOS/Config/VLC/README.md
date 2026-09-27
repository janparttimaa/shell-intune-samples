# VLC Policy Enforcer
In general, Mobile Device Management systems such as Microsoft Intune [support the distribution of standardized plist files to managed users](https://learn.microsoft.com/en-us/intune/intune-service/configuration/preference-file-settings-macos). This makes it straightforward to distribute updated plist files when a setting needs to be added, changed, or removed. These plist files are typically deployed to `/Library/Managed Preferences`.

This script addresses environments where VLC does not consume the required preference values from `/Library/Managed Preferences` and instead uses the per-user preference plist in `~/Library/Preferences`. It provides a way to deploy, modify, remove, and re-apply selected VLC preference values at the user level.

This custom script automates the configuration and enforcement of VLC settings at the user level on macOS devices. It is especially useful in **MDM deployment scenarios** such as Microsoft Intune, where consistent configuration across managed devices is important.

### Purpose

The script keeps selected VLC user preferences aligned with an administrator-defined configuration. Detailed create, update, delete, validation, and enforcement behavior is described in **What the Script Does** below.

### Benefits

- ✅ Ensures **consistent policy enforcement** across all managed Macs
- ✅ Reduces **manual configuration errors**
- ✅ Supports **centralized security configuration and hardening**
- ✅ Fully **automated and silent** when deployed via Intune
- ✅ Logs all actions for **auditability and troubleshooting**

---

### What the Script Does

Each time the script runs, it:

- **Creates** the VLC preference plist if it does not already exist
- **Adds** missing configured settings
- **Updates** settings with the wrong value or plist type
- **Leaves** settings unchanged when they already match
- **Deletes** keys configured for removal
- **Validates** the resulting plist
- **Refreshes** the signed-in user's preference cache
- **Logs** a warning if VLC is currently running without closing or interrupting it

Because configured values are applied every time the script runs, a preference changed manually by the user can be changed back to the configured value during a later enforcement run.

---

### Example Policies (`org.videolan.vlc.plist`)

The default **USER CONFIGURATION** section in the script contains these example settings:

| Key | Type | Value | Notes |
|-----|------|-------|-------|
| `language` | `string` | `en` | Sets the VLC language preference to "American English". |
| `SUEnableAutomaticChecks` | `bool` | `true` | Enables "Automatically check for updates". |

> [!NOTE]  
> These values are examples. Add, modify, or remove preference entries as required for your environment.

---

### Customization

Normal configuration changes should be made only between the **USER CONFIGURATION** and **END USER CONFIGURATION** markers.

```zsh
############################################################################################
# USER CONFIGURATION
#
# Modify the values in this section to configure VLC preferences.
# Do not modify the rest of the script unless you know what you are doing.
############################################################################################

# Language
set_plist_value "language" string "en"

# Sparkle updater preferences
set_plist_value "SUEnableAutomaticChecks" bool "true"

############################################################################################
# END USER CONFIGURATION
############################################################################################
```

Add, change, or delete preference commands inside this section.

#### Add or Update a Scalar Setting

For a normal single-value preference, use:

```zsh
set_plist_value "SETTING_NAME" TYPE "VALUE"
```

Examples:

```zsh
set_plist_value "language" string "en"
set_plist_value "SUEnableAutomaticChecks" bool "true"
set_plist_value "ExampleCount" integer "5"
```

The script automatically checks whether the key exists:

- If the key is missing, it is added.
- If the value differs, it is updated.
- If the plist type differs, the value is replaced using the configured type.
- If the value and type already match, no change is made.

There is no separate update command. To change a managed value, edit the existing `set_plist_value` entry.

For example:

```zsh
set_plist_value "language" string "en"
```

can be changed to:

```zsh
set_plist_value "language" string "fi"
```

#### Supported Scalar Types

| Type | Example |
|------|---------|
| `string` | `set_plist_value "ExampleName" string "VLC"` |
| `bool` | `set_plist_value "ExampleEnabled" bool "true"` |
| `integer` | `set_plist_value "ExampleCount" integer "10"` |
| `float` | `set_plist_value "ExampleVolume" float "0.75"` |
| `date` | `set_plist_value "ExampleDate" date "2026-09-27T08:12:39Z"` |
| `data` | `set_plist_value "ExampleData" data "SGVsbG8="` |

For Boolean values, use `true` or `false`.

For `data`, supply a Base64-encoded value.

#### Delete a Setting

To remove a preference from the VLC plist, use:

```zsh
delete_key "SETTING_NAME"
```

Example:

```zsh
delete_key "SUSendProfileInfo"
```

If the key exists, the script removes it. If the key is already absent, the script logs that there is nothing to delete and continues normally.

When changing a managed preference from **set** to **delete**, remove or comment out the corresponding `set_plist_value` line and add `delete_key` instead.

For example, replace:

```zsh
set_plist_value "SUSendProfileInfo" bool "false"
```

with:

```zsh
delete_key "SUSendProfileInfo"
```

> [!IMPORTANT]  
> Do not normally keep both a set and delete command for the same key. Commands are processed from top to bottom, so the last command for that key determines the final result.

#### Add an Array or Dictionary

For preferences containing an array or dictionary rather than a scalar value, use `set_plist_json`.

Array example:

```zsh
set_plist_json "ExampleArray" '["one","two","three"]'
```

Dictionary example:

```zsh
set_plist_json "ExampleDictionary" '{"Enabled":true,"Count":2}'
```

The JSON must be valid. Keep it inside single quotes so the shell does not interpret the double quotes inside the JSON.

To modify an existing array or dictionary, edit its JSON value. To remove it, use `delete_key`.

Example:

```zsh
delete_key "ExampleArray"
```

---

### Example USER CONFIGURATION

The following example combines scalar settings, an array, a dictionary, and a delete example:

```zsh
############################################################################################
# USER CONFIGURATION
############################################################################################

# Scalar settings
set_plist_value "language" string "en"
set_plist_value "SUEnableAutomaticChecks" bool "true"
set_plist_value "ExampleCount" integer "5"

# Array example
set_plist_json "ExampleArray" '["one","two"]'

# Dictionary example
set_plist_json "ExampleDictionary" '{"Enabled":true,"Count":2}'

# Remove a preference
# delete_key "SUSendProfileInfo"

############################################################################################
# END USER CONFIGURATION
############################################################################################
```

Remove the leading `#` from the `delete_key` example when you actually want that key removed.

---

### Requirements and Deployment Considerations

This README assumes deployment to macOS devices through an MDM platform such as Microsoft Intune. The documented Intune configuration runs the script as the signed-in user so that preferences are applied to that user's `~/Library/Preferences/org.videolan.vlc.plist`.

Compatibility can vary between VLC and macOS releases. Before production deployment, validate the targeted preference keys, plist types, and managed-preference behavior on a test Mac using the versions deployed in your environment. If your deployment must run when no user is signed in, test that scenario separately; it is not defined by the deployment settings documented here.

### Script Settings

| Setting | Value |
|---------|-------|
| Run script as signed-in user | ✅ Yes |
| Hide script notifications on devices | ✅ Yes |
| Script frequency | Every 1 day |
| Number of times to retry if script fails | 3 |

---

### Reading Existing VLC Preferences

Before adding a new policy, you can inspect VLC's existing preference plist with macOS `plutil`.

To display the plist:

```zsh
/usr/bin/plutil -p "$HOME/Library/Preferences/org.videolan.vlc.plist"
```

To inspect one known key:

```zsh
/usr/bin/plutil -extract "language" raw -o - "$HOME/Library/Preferences/org.videolan.vlc.plist"
```

To check the plist type of a key:

```zsh
/usr/bin/plutil -type "language" "$HOME/Library/Preferences/org.videolan.vlc.plist"
```

Use the actual plist type when creating the corresponding `set_plist_value` entry.

---

### Log File

The log file will output to ***~/Library/Logs/Microsoft/IntuneScripts/VLCPolicyEnforcerUserLevel/VLCPolicyEnforcerUserLevel.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sun 27 Sep 2026 12:36:00 EEST | Starting script VLCPolicyEnforcerUserLevel
##############################################################

Sun 27 Sep 2026 12:36:00 EEST | Applying VLC preferences...
Sun 27 Sep 2026 12:36:00 EEST | [CREATE] Creating empty VLC plist at /Users/johndoe/Library/Preferences/org.videolan.vlc.plist
Sun 27 Sep 2026 12:36:00 EEST | [ADD] language = en (string)
Sun 27 Sep 2026 12:36:00 EEST | [ADD] SUEnableAutomaticChecks = true (bool)
Sun 27 Sep 2026 12:36:00 EEST | [OK] Resulting VLC plist is valid.
Sun 27 Sep 2026 12:36:00 EEST | Refreshed the current user's preference cache.

Sun 27 Sep 2026 12:36:00 EEST | Script VLCPolicyEnforcerUserLevel completed.
##############################################################

##############################################################
# Sun 27 Sep 2026 12:39:08 EEST | Starting script VLCPolicyEnforcerUserLevel
##############################################################

Sun 27 Sep 2026 12:39:08 EEST | Applying VLC preferences...
Sun 27 Sep 2026 12:39:08 EEST | [UPDATE] language: fi (string) -> en (string)
Sun 27 Sep 2026 12:39:08 EEST | [OK] SUEnableAutomaticChecks is already set to true (bool)
Sun 27 Sep 2026 12:39:08 EEST | [OK] Resulting VLC plist is valid.
Sun 27 Sep 2026 12:39:08 EEST | Refreshed the current user's preference cache.

Sun 27 Sep 2026 12:39:08 EEST | Script VLCPolicyEnforcerUserLevel completed.
##############################################################
```