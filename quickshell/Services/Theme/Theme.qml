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

    readonly property string currentSchemeName: root.getSchemeDisplayName(root.currentSchemeType)

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
        root.currentSchemeType = schemeType;
        root.saveTheme();
        root.generateColors();
    }

    /* parsed color palette from json, auto-updates on mode change */
    property var colors: {
        const text = jsonFile.text();
        if (!text || !text.trim())
            return {};

        try {
            const data = JSON.parse(text);
            return data?.colors ?? {};
        } catch (e) {
            return {};
        }
    }

    /* surface colors */
    property color backgroundColor: root.colors.background
    property color surfaceColor: root.colors.surface
    property color surfaceBright: root.colors.surface_bright
    property color surfaceContainer: root.colors.surface_container
    property color surfaceContainerLow: root.colors.surface_container_low
    property color surfaceContainerHigh: root.colors.surface_container_high
    property color surfaceContainerHighest: root.colors.surface_container_highest
    property color surfaceDim: root.colors.surface_dim

    /* primary palette */
    property color primaryColor: root.colors.primary
    property color primaryContainer: root.colors.primary_container
    property color primaryFixed: root.colors.primary_fixed
    property color primaryFixedDim: root.colors.primary_fixed_dim

    /* secondary palette */
    property color secondaryColor: root.colors.secondary
    property color secondaryContainer: root.colors.secondary_container
    property color secondaryFixed: root.colors.secondary_fixed
    property color secondaryFixedDim: root.colors.secondary_fixed_dim

    /* tertiary palette */
    property color tertiaryColor: root.colors.tertiary
    property color tertiaryContainer: root.colors.tertiary_container
    property color tertiaryFixed: root.colors.tertiary_fixed
    property color tertiaryFixedDim: root.colors.tertiary_fixed_dim

    /* error palette */
    property color errorColor: root.colors.error
    property color errorContainer: root.colors.error_container

    /* text colors on surfaces */
    property color onBackground: root.colors.on_background
    property color onSurface: root.colors.on_surface
    property color onSurfaceVariant: root.colors.on_surface_variant

    /* text colors on primary */
    property color onPrimary: root.colors.on_primary
    property color onPrimaryContainer: root.colors.on_primary_container
    property color onPrimaryFixed: root.colors.on_primary_fixed
    property color onPrimaryFixedVariant: root.colors.on_primary_fixed_variant

    /* text colors on secondary */
    property color onSecondary: root.colors.on_secondary
    property color onSecondaryContainer: root.colors.on_secondary_container
    property color onSecondaryFixed: root.colors.on_secondary_fixed
    property color onSecondaryFixedVariant: root.colors.on_secondary_fixed_variant

    /* text colors on tertiary */
    property color onTertiary: root.colors.on_tertiary
    property color onTertiaryContainer: root.colors.on_tertiary_container
    property color onTertiaryFixed: root.colors.on_tertiary_fixed
    property color onTertiaryFixedVariant: root.colors.on_tertiary_fixed_variant

    /* text colors on error */
    property color onError: root.colors.on_error
    property color onErrorContainer: root.colors.on_error_container

    /* border colors */
    property color outlineColor: root.colors.outline
    property color outlineVariant: root.colors.outline_variant

    /* inverse theme colors */
    property color inverseSurface: root.colors.inverse_surface
    property color inverseOnSurface: root.colors.inverse_on_surface
    property color inversePrimary: root.colors.inverse_primary

    /* overlay colors */
    property color scrimColor: root.colors.scrim
    property color shadowColor: root.colors.shadow

    /* legacy aliases for backward compatibility */
    property color accentColor: root.primaryColor
    property color textColor: root.onBackground
    property color dimColor: root.outlineColor

    // kraken for theme config
    Kraken {
        id: themeKraken
        filePath: root.themePath

        onDataLoaded: {
            if (themeKraken.loaded && themeKraken.isObject) {
                if (themeKraken.has("isDarkMode")) {
                    root.isDarkMode = themeKraken.get("isDarkMode", true);
                }
                if (themeKraken.has("schemeType")) {
                    root.currentSchemeType = themeKraken.get("schemeType", "scheme-fruit-salad");
                }
                if (themeKraken.has("thumbPath")) {
                    root.thumbPath = themeKraken.get("thumbPath", "");
                }
                // generate colors on load if thumbPath exists
                if (root.thumbPath) {
                    root.generateColors();
                }
            }
        }

        onLoadFailed: error => {
            console.warn("theme config failed:", error);
            root.saveTheme();
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
            root.colorsChanged();
        }
    }

    onIsDarkModeChanged: {
        root.saveTheme();
        root.generateColors();
    }

    Process {
        id: matugenProcess
        onExited: reloadTimer.restart() //dogass
    }

    function generateColors() {
        if (!root.thumbPath) {
            return;
        }

        const cleanPath = root.thumbPath.replace("file://", "");
        const mode = root.isDarkMode ? "dark" : "light";
        const scheme = root.currentSchemeType;

        matugenProcess.command = ["/bin/sh", "-c", `matugen image "${cleanPath}" -m "${mode}" -t "${scheme}"`];
        matugenProcess.running = true;
    }

    function saveTheme() {
        themeKraken.set("isDarkMode", root.isDarkMode);
        themeKraken.set("schemeType", root.currentSchemeType);
        themeKraken.set("thumbPath", root.thumbPath);
        themeKraken.save();
    }

    function toggleMode() {
        root.isDarkMode = !root.isDarkMode;
    }
}
