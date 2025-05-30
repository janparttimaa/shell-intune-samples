# Adobe Acrobat Policy Enforcers
In generally, Mobile Device Management systems like Microsoft Intune [support the distribution of standardized plist files to managed users](https://learn.microsoft.com/en-us/intune/intune-service/configuration/preference-file-settings-macos). This also makes it easy to distribute updated plist files to users when a specific setting needs to be changed, removed, or added. These plist files are typically deployed to the `/Library/Managed Preferences` location. 

Unfortunately, some applications, such as Adobe Acrobat, do not support reading plist files from this location. Instead, they read from `/Library/Preferences` and/or `~/Library/Preferences`. These policy enforcer scripts are specifically developed for such applications that do not support reading deployed plist files from `/Library/Managed Preferences`. The goal is to provide an easy way to distribute configuration values to these applications, whether it's for deploying new settings, modifying existing ones, or removing deprecated entries.

In this example, we provide two policy enforcer scripts:
- **Combined Adobe Acrobat Policy Enforcer (Machine Level):** Configuration and enforcement of Adobe Acrobat FeatureLockDown and NGL (Next Generation Licensing) policies.
- **Adobe Acrobat Policy Enforcer (User Level):** Configuration and enforcement of Adobe Acrobat policies, that cannot be locked down.

## Combined Adobe Acrobat Policy Enforcer (Machine Level)
> [!NOTE]  
> This script can be deployed as separate script deployment but also with post-install script during Adobe Acrobat installation via Intune. We recommended to use both of the options.

This custom script is designed to **automate the configuration and enforcement of Adobe Acrobat FeatureLockDown and NGL (Next Generation Licensing) policies** on macOS devices. It is especially useful in **MDM deployment scenarios** such as Microsoft Intune, where consistent and secure configuration across devices is critical.

### Purpose

This script ensures that key Adobe Acrobat settings are **created, updated, or removed** at the machine level using `PlistBuddy`. It helps enforce security, compliance, and user experience standards by:

- Disabling unnecessary or insecure features
- Enabling enterprise-grade protections
- Pre-configuring login domains for Adobe licensing
- Preventing users from changing critical settings

### Benefits

- ✅ Ensures **consistent policy enforcement** across all managed Macs
- ✅ Reduces **manual configuration errors**
- ✅ Supports **CIS/NIST-aligned hardening**
- ✅ Fully **automated and silent** when deployed via Intune
- ✅ Logs all actions for **auditability and troubleshooting**

---
### What the Script Does

The script uses `PlistBuddy` to:

- **Create** missing `.plist` files and directories
- **Add or update** specific keys and values
- **Delete** obsolete or undesired keys (optional)

#### FeatureLockDown Policies (com.adobe.Acrobat.Pro.plist)

> [!NOTE]  
> - These are example settings and their values for example purposes. Feel free to do needed modifications before deploying this script to managed devices.
> - In this context, boolean value `false` is same as numeric value of 0, and a value of `true` mean same as numeric value of 1. This is good to know when checking notes from these example settings.
> - It is recommeded to check [Acrobat Desktop Machintosh Admin Guide](https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide_Mac/predeployment_configuration_advanced.html), before defining your settings and values.
> - Example settings are for Adobe Acrobat Continuous Release (DC).

| Key Path | Type | Value | Notes
|----------|------|-------|-------|
| `DC:FeatureLockdown:bProtectedMode` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/Privileged.html#idmackeyname_1_18132). |
| `DC:FeatureLockdown:bToggleShareFeedback` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_10673). |
| `DC:FeatureLockdown:bToggleFTE` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_10673). |
| `DC:FeatureLockdown:bWhatsNewExp` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_8752). |
| `DC:FeatureLockdown:bSuppressSignOut` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_10405). |
| `DC:FeatureLockdown:bEnableCertificateBasedTrust` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/TrustManager.html#idmackeyname_1_29347). |
| `DC:FeatureLockdown:bEnhancedSecurityInBrowser` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/TrustManager.html#idmackeyname_1_27900). |
| `DC:FeatureLockdown:bEnhancedSecurityStandalone` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/TrustManager.html#idmackeyname_1_27949). |
| `DC:FeatureLockdown:bMIPLabelling` | `bool` | `true` | [More information](https://helpx.adobe.com/enterprise/kb/mpip-support-acrobat.html). |
| `DC:FeatureLockdown:bMIPCheckPolicyOnDocSave` | `bool` | `true` | [More information](https://helpx.adobe.com/enterprise/kb/mpip-support-acrobat.html). |
| `DC:FeatureLockdown:bEnableAV2Enterprise` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_8801). |
| `DC:FeatureLockdown:bUpdater` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9156). |
| `DC:FeatureLockdown:bAcroSuppressUpsell` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_11883). |
| `DC:FeatureLockdown:cWebmailProfiles:bDisableWebmail` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/WebMail.html#idmackeyname_1_30996). |
| `DC:FeatureLockdown:cSharePoint:bDisableSharePointFeatures` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/Workflows.html?#idmackeyname_1_32236). |
| `DC:FeatureLockdown:cWelcomeScreen:bShowWelcomeScreen` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/AVGeneral.html?#idmackeyname_1_6139). |
| `DC:FeatureLockdown:cIPM:bShowMsgAtLaunch` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/IPM.html#idmackeyname_1_15704). |
| `DC:FeatureLockdown:cIPM:bDontShowMsgWhenViewingDoc` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/IPM.html#idmackeyname_1_15660). |
| `DC:FeatureLockdown:cIPM:bAllowUserToChangeMsgPrefs` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/IPM.html#idmackeyname_1_15751). |
| `DC:FeatureLockdown:cServices:bToggleWebConnectors` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9923). |
| `DC:FeatureLockdown:cServices:bOneDriveConnectorEnabled` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_10068). |
| `DC:FeatureLockdown:cServices:bBoxConnectorEnabled` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9968). |
| `DC:FeatureLockdown:cServices:bDropboxConnectorEnabled` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_10018). |
| `DC:FeatureLockdown:cServices:bGoogleDriveConnectorEnabled` | `bool` | `false` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_10118). |
| `DC:FeatureLockdown:cServices:bToggleAdobeDocumentServices` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9206). |
| `DC:FeatureLockdown:cServices:bToggleNotifications` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9700). |
| `DC:FeatureLockdown:cServices:bToggleSendACopy` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9257). |
| `DC:FeatureLockdown:cServices:bToggleAdobeSign` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9394). |
| `DC:FeatureLockdown:cServices:bToggleManageSign` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9350). |
| `DC:FeatureLockdown:cServices:bUpdater` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9156). |
| `DC:FeatureLockdown:cServices:bTogglePrefsSync` | `bool` | `true` | [More information](https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Macintosh/FeatureLockDown.html#idmackeyname_1_9584). |
| `NGL:AuthInfo:enabled_social_providers` | `string` | `""` | Hide social media sign-in options (e.g. Facebook) from Adobe Acrobat's sign-in screen. |
| `NGL:Config:EnableExternalBrowserAuth` | `bool` | `true` | Makes sure, that external browser will be used during sign-in process. |

#### NGL Login Domain Policy (com.adobe.NGL.AuthInfo.plist)

| Key Path | Type | Value | Notes
|----------|------|-------|-------|
| `AuthInfo:login_domain` | `string` | `example.com` | Specify login domain, that will be use, when signing into Adobe-products e.g. Adobe Acrobat DC. Replace with your actual domain. [More information](https://helpx.adobe.com/enterprise/using/enterprise-device-authentication-management.html).|

---

### Customization

To **modify or extend** the script:

- To **add a new key**, use the `acrobat_enforce_value` or `ngl_enforce_value` function.
- To **delete a key**, uncomment and use `acrobat_delete_key` or `ngl_delete_key`.
- To **change the login domain**, edit the `domain="example.com"` variable near the top of the script.

---

### Script Settings

| Setting | Value |
|--------|-------|
| Run script as signed-in user | ❌ No |
| Hide script notifications on devices | ✅ Yes |
| Script frequency | Every 1 day |
| Number of times to retry if script fails | 3 |

---

### Log File

The log file will output to ***/Library/Logs/Microsoft/IntuneScripts/AdobeAcrobatCombinedPolicyEnforcerMachineLevel/AdobeAcrobatCombinedPolicyEnforcerMachineLevel.log*** by default. Exit status is either 0 or 1. To gather this log with Intune remotely take a look at  [Troubleshoot macOS shell script policies using log collection](https://docs.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts#troubleshoot-macos-shell-script-policies-using-log-collection)

```
##############################################################
# Sat May 31 13:39:11 EEST 2025 | Starting running of script AdobeAcrobatCombinedPolicyEnforcerMachineLevel
##############################################################

Sat May 31 13:39:11 EEST 2025 | Applying Adobe Acrobat FeatureLockDown policies...
Sat May 31 13:39:11 EEST 2025 | Directory already exists: /Library/Preferences
Sat May 31 13:39:11 EEST 2025 | [CREATE] Creating empty plist at /Library/Preferences/com.adobe.Acrobat.Pro.plist
Sat May 31 13:39:11 EEST 2025 | [ADD] Creating missing dictionary: DC
Sat May 31 13:39:11 EEST 2025 | [ADD] Creating missing dictionary: DC:FeatureLockdown
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bProtectedMode = false
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bToggleShareFeedback = false
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bToggleFTE = true
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bWhatsNewExp = false
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bSuppressSignOut = true
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bEnableCertificateBasedTrust = true
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bEnhancedSecurityInBrowser = true
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bEnhancedSecurityStandalone = true
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bMIPLabelling = true
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bMIPCheckPolicyOnDocSave = true
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bEnableAV2Enterprise = false
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bUpdater = true
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:bAcroSuppressUpsell = true
Sat May 31 13:39:11 EEST 2025 | [ADD] Creating missing dictionary: DC:FeatureLockdown:cWebmailProfiles
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:cWebmailProfiles:bDisableWebmail = true
Sat May 31 13:39:11 EEST 2025 | [ADD] Creating missing dictionary: DC:FeatureLockdown:cSharePoint
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:cSharePoint:bDisableSharePointFeatures = false
Sat May 31 13:39:11 EEST 2025 | [ADD] Creating missing dictionary: DC:FeatureLockdown:cWelcomeScreen
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:cWelcomeScreen:bShowWelcomeScreen = true
Sat May 31 13:39:11 EEST 2025 | [ADD] Creating missing dictionary: DC:FeatureLockdown:cIPM
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:cIPM:bShowMsgAtLaunch = false
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:cIPM:bDontShowMsgWhenViewingDoc = false
Sat May 31 13:39:11 EEST 2025 | [ADD] DC:FeatureLockdown:cIPM:bAllowUserToChangeMsgPrefs = false
Sat May 31 13:39:11 EEST 2025 | [ADD] Creating missing dictionary: DC:FeatureLockdown:cServices
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bToggleWebConnectors = true
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bOneDriveConnectorEnabled = false
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bBoxConnectorEnabled = false
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bDropboxConnectorEnabled = false
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bGoogleDriveConnectorEnabled = false
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bToggleAdobeDocumentServices = true
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bToggleNotifications = true
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bToggleSendACopy = true
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bToggleAdobeSign = true
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bToggleManageSign = true
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bUpdater = true
Sat May 31 13:39:12 EEST 2025 | [ADD] DC:FeatureLockdown:cServices:bTogglePrefsSync = true
Sat May 31 13:39:12 EEST 2025 | [ADD] Creating missing dictionary: NGL
Sat May 31 13:39:12 EEST 2025 | [ADD] Creating missing dictionary: NGL:AuthInfo
Sat May 31 13:39:12 EEST 2025 | [ADD] NGL:AuthInfo:enabled_social_providers = 
Sat May 31 13:39:12 EEST 2025 | [ADD] Creating missing dictionary: NGL:Config
Sat May 31 13:39:12 EEST 2025 | [ADD] NGL:Config:EnableExternalBrowserAuth = true

Sat May 31 13:39:12 EEST 2025 | Applying NGL AuthInfo policy for login_domain...
Sat May 31 13:39:12 EEST 2025 | Directory already exists: /Library/Preferences
Sat May 31 13:39:12 EEST 2025 | [CREATE] Creating empty plist at /Library/Preferences/com.adobe.NGL.AuthInfo.plist
Sat May 31 13:39:12 EEST 2025 | [ADD] Creating missing dictionary: AuthInfo
Sat May 31 13:39:12 EEST 2025 | [ADD] AuthInfo:login_domain = example.com

Sat May 31 13:39:12 EEST 2025 | Script AdobeAcrobatCombinedPolicyEnforcerMachineLevel completed.
##############################################################

##############################################################
# Sat May 31 13:49:30 EEST 2025 | Starting running of script AdobeAcrobatCombinedPolicyEnforcerMachineLevel
##############################################################

Sat May 31 13:49:30 EEST 2025 | Applying Adobe Acrobat FeatureLockDown policies...
Sat May 31 13:49:30 EEST 2025 | Directory already exists: /Library/Preferences
Sat May 31 13:49:30 EEST 2025 | [UPDATE] DC:FeatureLockdown:bProtectedMode: true -> false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bToggleShareFeedback is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bToggleFTE is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bWhatsNewExp is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bSuppressSignOut is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bEnableCertificateBasedTrust is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bEnhancedSecurityInBrowser is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bEnhancedSecurityStandalone is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bMIPLabelling is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bMIPCheckPolicyOnDocSave is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bEnableAV2Enterprise is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bUpdater is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:bAcroSuppressUpsell is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cWebmailProfiles:bDisableWebmail is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cSharePoint:bDisableSharePointFeatures is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cWelcomeScreen:bShowWelcomeScreen is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cIPM:bShowMsgAtLaunch is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cIPM:bDontShowMsgWhenViewingDoc is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cIPM:bAllowUserToChangeMsgPrefs is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bToggleWebConnectors is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bOneDriveConnectorEnabled is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bBoxConnectorEnabled is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bDropboxConnectorEnabled is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bGoogleDriveConnectorEnabled is already set to false
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bToggleAdobeDocumentServices is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bToggleNotifications is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bToggleSendACopy is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bToggleAdobeSign is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bToggleManageSign is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bUpdater is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] DC:FeatureLockdown:cServices:bTogglePrefsSync is already set to true
Sat May 31 13:49:30 EEST 2025 | [OK] NGL:AuthInfo:enabled_social_providers is already set to 
Sat May 31 13:49:30 EEST 2025 | [OK] NGL:Config:EnableExternalBrowserAuth is already set to true

Sat May 31 13:49:30 EEST 2025 | Applying NGL AuthInfo policy for login_domain...
Sat May 31 13:49:30 EEST 2025 | Directory already exists: /Library/Preferences
Sat May 31 13:49:30 EEST 2025 | [OK] AuthInfo:login_domain is already set to example.com

Sat May 31 13:49:30 EEST 2025 | Script AdobeAcrobatCombinedPolicyEnforcerMachineLevel completed.
##############################################################
```