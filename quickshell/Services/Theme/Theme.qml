pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Kraken
import qs.Services.Paths

Singleton {
    id: root

    readonly property string themePath: PathService.home + "/.cache/safalQuick/theme.json"
    readonly property string colorsPath: PathService.home + "/.cache/safalQuick/colors.json"

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

    property var _c: ({})

    function _get(key, fallback) {
        return root._c[key] !== undefined ? root._c[key] : fallback;
    }

    /* surface colors */
    property color backgroundColor: root._get("background", "#000000")
    property color surfaceColor: root._get("surface", "#0a0a0a")
    property color surfaceBright: root._get("surface_bright", "#1a1a1a")
    property color surfaceContainer: root._get("surface_container", "#111111")
    property color surfaceContainerLow: root._get("surface_container_low", "#0d0d0d")
    property color surfaceContainerHigh: root._get("surface_container_high", "#1c1c1c")
    property color surfaceContainerHighest: root._get("surface_container_highest", "#242424")
    property color surfaceDim: root._get("surface_dim", "#080808")

    /* primary palette */
    property color primaryColor: root._get("primary", "#c0c0c0")
    property color primaryContainer: root._get("primary_container", "#2a2a2a")
    property color primaryFixed: root._get("primary_fixed", "#d0d0d0")
    property color primaryFixedDim: root._get("primary_fixed_dim", "#a0a0a0")

    /* secondary palette */
    property color secondaryColor: root._get("secondary", "#a0a0a0")
    property color secondaryContainer: root._get("secondary_container", "#222222")
    property color secondaryFixed: root._get("secondary_fixed", "#b0b0b0")
    property color secondaryFixedDim: root._get("secondary_fixed_dim", "#888888")

    /* tertiary palette */
    property color tertiaryColor: root._get("tertiary", "#808080")
    property color tertiaryContainer: root._get("tertiary_container", "#1e1e1e")
    property color tertiaryFixed: root._get("tertiary_fixed", "#909090")
    property color tertiaryFixedDim: root._get("tertiary_fixed_dim", "#686868")

    /* error palette */
    property color errorColor: root._get("error", "#cf6679")
    property color errorContainer: root._get("error_container", "#3b1218")

    /* text colors on surfaces */
    property color onBackground: root._get("on_background", "#e0e0e0")
    property color onSurface: root._get("on_surface", "#e0e0e0")
    property color onSurfaceVariant: root._get("on_surface_variant", "#909090")

    /* text colors on primary */
    property color onPrimary: root._get("on_primary", "#000000")
    property color onPrimaryContainer: root._get("on_primary_container", "#e0e0e0")
    property color onPrimaryFixed: root._get("on_primary_fixed", "#000000")
    property color onPrimaryFixedVariant: root._get("on_primary_fixed_variant", "#1a1a1a")

    /* text colors on secondary */
    property color onSecondary: root._get("on_secondary", "#000000")
    property color onSecondaryContainer: root._get("on_secondary_container", "#e0e0e0")
    property color onSecondaryFixed: root._get("on_secondary_fixed", "#000000")
    property color onSecondaryFixedVariant: root._get("on_secondary_fixed_variant", "#1a1a1a")

    /* text colors on tertiary */
    property color onTertiary: root._get("on_tertiary", "#000000")
    property color onTertiaryContainer: root._get("on_tertiary_container", "#e0e0e0")
    property color onTertiaryFixed: root._get("on_tertiary_fixed", "#000000")
    property color onTertiaryFixedVariant: root._get("on_tertiary_fixed_variant", "#1a1a1a")

    /* text colors on error */
    property color onError: root._get("on_error", "#000000")
    property color onErrorContainer: root._get("on_error_container", "#cf6679")

    /* border colors */
    property color outlineColor: root._get("outline", "#3a3a3a")
    property color outlineVariant: root._get("outline_variant", "#2a2a2a")

    /* inverse theme colors */
    property color inverseSurface: root._get("inverse_surface", "#e0e0e0")
    property color inverseOnSurface: root._get("inverse_on_surface", "#1a1a1a")
    property color inversePrimary: root._get("inverse_primary", "#3a3a3a")

    /* overlay colors */
    property color scrimColor: root._get("scrim", "#000000")
    property color shadowColor: root._get("shadow", "#000000")

    /* legacy aliases */
    property color accentColor: root.primaryColor
    property color textColor: root.onBackground
    property color dimColor: root.outlineColor

    FileView {
        id: jsonFile
        path: root.colorsPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const data = JSON.parse(jsonFile.text());
                root._c = data?.colors ?? {};
                root._cChanged();
            } catch (e) {
                root._c = {};
                root._cChanged();
            }
        }
    }

    on_CChanged: {
        root.backgroundColor = root._get("background", "#000000");
        root.surfaceColor = root._get("surface", "#0a0a0a");
        root.surfaceBright = root._get("surface_bright", "#1a1a1a");
        root.surfaceContainer = root._get("surface_container", "#111111");
        root.surfaceContainerLow = root._get("surface_container_low", "#0d0d0d");
        root.surfaceContainerHigh = root._get("surface_container_high", "#1c1c1c");
        root.surfaceContainerHighest = root._get("surface_container_highest", "#242424");
        root.surfaceDim = root._get("surface_dim", "#080808");
        root.primaryColor = root._get("primary", "#c0c0c0");
        root.primaryContainer = root._get("primary_container", "#2a2a2a");
        root.primaryFixed = root._get("primary_fixed", "#d0d0d0");
        root.primaryFixedDim = root._get("primary_fixed_dim", "#a0a0a0");
        root.secondaryColor = root._get("secondary", "#a0a0a0");
        root.secondaryContainer = root._get("secondary_container", "#222222");
        root.secondaryFixed = root._get("secondary_fixed", "#b0b0b0");
        root.secondaryFixedDim = root._get("secondary_fixed_dim", "#888888");
        root.tertiaryColor = root._get("tertiary", "#808080");
        root.tertiaryContainer = root._get("tertiary_container", "#1e1e1e");
        root.tertiaryFixed = root._get("tertiary_fixed", "#909090");
        root.tertiaryFixedDim = root._get("tertiary_fixed_dim", "#686868");
        root.errorColor = root._get("error", "#cf6679");
        root.errorContainer = root._get("error_container", "#3b1218");
        root.onBackground = root._get("on_background", "#e0e0e0");
        root.onSurface = root._get("on_surface", "#e0e0e0");
        root.onSurfaceVariant = root._get("on_surface_variant", "#909090");
        root.onPrimary = root._get("on_primary", "#000000");
        root.onPrimaryContainer = root._get("on_primary_container", "#e0e0e0");
        root.onPrimaryFixed = root._get("on_primary_fixed", "#000000");
        root.onPrimaryFixedVariant = root._get("on_primary_fixed_variant", "#1a1a1a");
        root.onSecondary = root._get("on_secondary", "#000000");
        root.onSecondaryContainer = root._get("on_secondary_container", "#e0e0e0");
        root.onSecondaryFixed = root._get("on_secondary_fixed", "#000000");
        root.onSecondaryFixedVariant = root._get("on_secondary_fixed_variant", "#1a1a1a");
        root.onTertiary = root._get("on_tertiary", "#000000");
        root.onTertiaryContainer = root._get("on_tertiary_container", "#e0e0e0");
        root.onTertiaryFixed = root._get("on_tertiary_fixed", "#000000");
        root.onTertiaryFixedVariant = root._get("on_tertiary_fixed_variant", "#1a1a1a");
        root.onError = root._get("on_error", "#000000");
        root.onErrorContainer = root._get("on_error_container", "#cf6679");
        root.outlineColor = root._get("outline", "#3a3a3a");
        root.outlineVariant = root._get("outline_variant", "#2a2a2a");
        root.inverseSurface = root._get("inverse_surface", "#e0e0e0");
        root.inverseOnSurface = root._get("inverse_on_surface", "#1a1a1a");
        root.inversePrimary = root._get("inverse_primary", "#3a3a3a");
        root.scrimColor = root._get("scrim", "#000000");
        root.shadowColor = root._get("shadow", "#000000");
    }

    Kraken {
        id: themeKraken
        filePath: root.themePath

        onDataLoaded: {
            if (themeKraken.loaded && themeKraken.isObject) {
                root.currentSchemeType = themeKraken.get("schemeType", "scheme-fruit-salad");
                const saved = themeKraken.get("thumbPath", "");
                root.thumbPath = saved ? PathService.home + '/thumbs/' + saved : "";
                root.isDarkMode = themeKraken.get("isDarkMode", true);
            }
        }

        onLoadFailed: error => {
            console.warn("theme config failed:", error);
            root.saveTheme();
        }
    }

    onIsDarkModeChanged: {
        root.saveTheme();
        root.generateColors();
    }

    function generateColors() {
        if (!root.thumbPath)
            return;
        const mode = root.isDarkMode ? "dark" : "light";
        Quickshell.execDetached(["/bin/sh", "-c", `matugen --source-color-index 0 -m "${mode}" -t "${root.currentSchemeType}" image "${root.thumbPath}"`]);
    }

    function saveTheme() {
        themeKraken.set("isDarkMode", root.isDarkMode);
        themeKraken.set("schemeType", root.currentSchemeType);
        if (root.thumbPath) {
            const filename = root.thumbPath.split("/").pop();
            themeKraken.set("thumbPath", filename);
        }
        themeKraken.save();
    }

    function toggleMode() {
        root.isDarkMode = !root.isDarkMode;
    }
}
