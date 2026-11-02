// LibreWolf prefs for the shin profile, applied on every start (LibreWolf's own
// defaults are in /usr/lib/librewolf/librewolf.cfg). The profile has a fixed name
// so chezmoi can put chrome/ and extensions/ in it: ../profiles.ini and
// ../installs.ini point LibreWolf at it (6C1CE26D3274EA5B is the hash of
// /usr/lib/librewolf), and chezmoi only writes them when they're missing.

// chrome/userChrome.css and chrome/userContent.css: the terminal look.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.uidensity", 1); // compact
user_pref("browser.compactmode.show", true);

// extensions/: the add-ons fetched by run_onchange_after_librewolf-addons.sh and
// our own unsigned shin@local (start page, theme colors, media position for
// waybar). Dropped-in add-ons start enabled instead of waiting for approval.
user_pref("xpinstall.signatures.required", false);
user_pref("extensions.autoDisableScopes", 0);

// The tab strip is the title bar (double-click maximizes, drag moves), like
// Firefox; userChrome.css hides its minimize/maximize/close buttons.
user_pref("browser.tabs.inTitlebar", 1);

// Websites get dark mode. LibreWolf's resistFingerprinting always reports light;
// fingerprintingProtection with every target (the same protections) except the
// color scheme keeps the rest.
user_pref("privacy.resistFingerprinting", false);
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.fingerprintingProtection.pbmode", true);
user_pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CSSPrefersColorScheme");
user_pref("layout.css.prefers-color-scheme.content-override", 0); // dark

// Stay logged in: LibreWolf deletes cookies and site data on every quit. Its
// other cleanup on quit (the cache) stays on.
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);

// Dark menus and about: pages, also before shin@local's colors load.
user_pref("ui.systemUsesDarkTheme", 1);
