pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Kraken

Singleton {
    id: root

    readonly property string themePath: Quickshell.env("HOME") + "/.cache/safalQuick/theme.json"
    readonly property string colorsPath: Quickshell.env("HOME") + "/.cache/safalQuick/colors.json"

    property bool isDarkMode: true
    property string currentSchemeType: "scheme-fruit-salad"
    property string thumbPath: ""

    readonly property var schemeTypes: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot", "scheme-vibrant"]

    readonly property string currentSchemeName: getSchemeDisplayName(currentSchemeType)

    function getSchemeDisplayName(schemeType) {
        const names = {
            "scheme-content": "Content",
            "scheme-expressive": "Expressive",
            "scheme-fidelity": "Fidelity",
            "scheme-fruit-salad": "Fruit Salad",
            "scheme-monochrome": "Monochrome",
            "scheme-neutral": "Neutral",
            "scheme-rainbow": "Rainbow",
            "scheme-tonal-spot": "Tonal Spot",
            "scheme-vibrant": "Vibrant"
        };
        return names[schemeType] || schemeType;
    }

    function setSchemeType(schemeType) {
        currentSchemeType = schemeType;
        saveTheme();
        generateColors();
    }

    /* parsed color palette from json, auto-updates on mode change */
    property var colors: {
        const text = jsonFile.text();
        if (!text?.trim())
            return {};

        try {
            const data = JSON.parse(text);
            return data?.colors ?? {};
        } catch (e) {
            return {};
        }
    }

    /* surface colors */
    property color backgroundColor: colors.background
    property color surfaceColor: colors.surface
    property color surfaceBright: colors.surface_bright
    property color surfaceContainer: colors.surface_container
    property color surfaceContainerLow: colors.surface_container_low
    property color surfaceContainerHigh: colors.surface_container_high
    property color surfaceContainerHighest: colors.surface_container_highest
    property color surfaceDim: colors.surface_dim

    /* primary palette */
    property color primaryColor: colors.primary
    property color primaryContainer: colors.primary_container
    property color primaryFixed: colors.primary_fixed
    property color primaryFixedDim: colors.primary_fixed_dim

    /* secondary palette */
    property color secondaryColor: colors.secondary
    property color secondaryContainer: colors.secondary_container
    property color secondaryFixed: colors.secondary_fixed
    property color secondaryFixedDim: colors.secondary_fixed_dim

    /* tertiary palette */
    property color tertiaryColor: colors.tertiary
    property color tertiaryContainer: colors.tertiary_container
    property color tertiaryFixed: colors.tertiary_fixed
    property color tertiaryFixedDim: colors.tertiary_fixed_dim

    /* error palette */
    property color errorColor: colors.error
    property color errorContainer: colors.error_container

    /* text colors on surfaces */
    property color onBackground: colors.on_background
    property color onSurface: colors.on_surface
    property color onSurfaceVariant: colors.on_surface_variant

    /* text colors on primary */
    property color onPrimary: colors.on_primary
    property color onPrimaryContainer: colors.on_primary_container
    property color onPrimaryFixed: colors.on_primary_fixed
    property color onPrimaryFixedVariant: colors.on_primary_fixed_variant

    /* text colors on secondary */
    property color onSecondary: colors.on_secondary
    property color onSecondaryContainer: colors.on_secondary_container
    property color onSecondaryFixed: colors.on_secondary_fixed
    property color onSecondaryFixedVariant: colors.on_secondary_fixed_variant

    /* text colors on tertiary */
    property color onTertiary: colors.on_tertiary
    property color onTertiaryContainer: colors.on_tertiary_container
    property color onTertiaryFixed: colors.on_tertiary_fixed
    property color onTertiaryFixedVariant: colors.on_tertiary_fixed_variant

    /* text colors on error */
    property color onError: colors.on_error
    property color onErrorContainer: colors.on_error_container

    /* border colors */
    property color outlineColor: colors.outline
    property color outlineVariant: colors.outline_variant

    /* inverse theme colors */
    property color inverseSurface: colors.inverse_surface
    property color inverseOnSurface: colors.inverse_on_surface
    property color inversePrimary: colors.inverse_primary

    /* overlay colors */
    property color scrimColor: colors.scrim
    property color shadowColor: colors.shadow

    /* legacy aliases for backward compatibility */
    property color accentColor: primaryColor
    property color textColor: onBackground
    property color dimColor: outlineColor

    // kraken for theme config
    Kraken {
        id: themeKraken
        filePath: root.themePath

        onDataLoaded: {
            if (loaded && isObject) {
                if (has("isDarkMode")) {
                    root.isDarkMode = get("isDarkMode", true);
                }
                if (has("schemeType")) {
                    root.currentSchemeType = get("schemeType", "scheme-fruit-salad");
                }
                if (has("thumbPath")) {
                    root.thumbPath = get("thumbPath", "");
                }
                // generate colors on load if thumbPath exists
                if (root.thumbPath) {
                    generateColors();
                }
            }
        }

        onLoadFailed: error => {
            console.warn("theme config failed:", error);
            saveTheme();
        }
    }

    FileView {
        id: jsonFile
        path: root.colorsPath
        blockLoading: true
        watchChanges: true
        onFileChanged: reloadTimer.restart()
    }

    FileView {
        id: themeFile
        path: root.themePath
        blockLoading: true
        watchChanges: true
        onFileChanged: {
            themeKraken.reload();
        }
    }

    Timer {
        id: reloadTimer
        interval: 100
        onTriggered: {
            jsonFile.reload();
            colorsChanged();
            console.log("test");
        }
    }

    onIsDarkModeChanged: {
        saveTheme();
        generateColors();
    }

    Process {
        id: matugenProcess
        onExited: reloadTimer.restart()
    }

    function generateColors() {
        if (!thumbPath) {
            return;
        }

        const cleanPath = thumbPath.replace("file://", "");
        const mode = isDarkMode ? "dark" : "light";
        const scheme = currentSchemeType;

        matugenProcess.command = ["/bin/sh", "-c", `matugen image "${cleanPath}" -m "${mode}" -t "${scheme}"`];
        matugenProcess.running = true;
    }

    function saveTheme() {
        themeKraken.set("isDarkMode", isDarkMode);
        themeKraken.set("schemeType", currentSchemeType);
        themeKraken.set("thumbPath", thumbPath);
        themeKraken.save();
    }

    function toggleMode() {
        isDarkMode = !isDarkMode;
    }
}
