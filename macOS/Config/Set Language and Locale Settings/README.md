# Set Language and Locale Settings
This custom script configures language and locale settings on macOS devices for both the system/login window and the currently signed-in user.

By default, the script configures following language and locale as an example:

| Language    | Notes       |
| ----------- | ----------- |
| `en-US`     | The target language to set in BCP 47 format (e.g., `en-US`, `fr-FR`, `es-ES`, etc.) |

| Locale      | Notes       |
| ----------- | ----------- |
| `fi_FI`     | The target locale to set in Apple/POSIX-style locale notation (e.g., `en_US`, `fr_FR`, `es_ES`, etc.) |

**Important:** Before deploying the script, please define appropriate values to lines 23 and 24.

The script also checks whether the device is Apple Business Manager (ABM) managed before applying the settings.

## Script Settings

- Run script as signed-in user : No
- Hide script notifications on devices : Yes
- Script frequency : Every 1 day
- Number of times to retry if script fails : 3

## Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/SetLanguageAndLocaleSettings/SetLanguageAndLocaleSettings.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

Example log output:

```text
##############################################################
# Sun Sep 20 11:58:00 EEST 2026 | Starting running of script SetLanguageAndLocaleSettings
##############################################################

Sun Sep 20 11:58:00 EEST 2026 | Checking MDM Profile Type
Enrolled via DEP: Yes
Sun Sep 20 11:58:01 EEST 2026 | Device is ABM Managed
Sun Sep 20 11:58:01 EEST 2026 | Checking system/login-window language and locale...
Sun Sep 20 11:58:01 EEST 2026 | Current system language: en-US
Sun Sep 20 11:58:01 EEST 2026 | Required system language: en-US
Sun Sep 20 11:58:01 EEST 2026 | Current system locale: fi_FI
Sun Sep 20 11:58:01 EEST 2026 | Required system locale: fi_FI
Sun Sep 20 11:58:01 EEST 2026 | System language is already set correctly.
Sun Sep 20 11:58:01 EEST 2026 | System locale is already set correctly.
Sun Sep 20 11:58:01 EEST 2026 | Final system language: en-US
Sun Sep 20 11:58:01 EEST 2026 | Final system locale: fi_FI
Sun Sep 20 11:58:01 EEST 2026 | System/login-window language and locale are configured correctly.
Sun Sep 20 11:58:01 EEST 2026 | Logged-in user: user
Sun Sep 20 11:58:01 EEST 2026 | Current language: en-US
Sun Sep 20 11:58:01 EEST 2026 | Required language: en-US
Sun Sep 20 11:58:01 EEST 2026 | Current locale: fi_FI
Sun Sep 20 11:58:01 EEST 2026 | Required locale: fi_FI
Sun Sep 20 11:58:01 EEST 2026 | Language is already set correctly.
Sun Sep 20 11:58:01 EEST 2026 | Locale is already set correctly.
Sun Sep 20 11:58:01 EEST 2026 | Final language: en-US
Sun Sep 20 11:58:01 EEST 2026 | Final locale: fi_FI
Sun Sep 20 11:58:01 EEST 2026 | User language and locale are configured correctly.
Sun Sep 20 11:58:01 EEST 2026 | All applicable language and locale settings are configured correctly. Closing script...
```