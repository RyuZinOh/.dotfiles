pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isDarkMode: {
        modeFile.reload();
        const text = modeFile.text()?.trim();
        return text === "dark" || text === "" || !text;
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

    //watches colors.json
    FileView {
        id: jsonFile
        path: "file:///home/safal726/.cache/safalQuick/colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reloadTimer.restart()
    }
    /* reads persisted theme mode */
    FileView {
        id: modeFile
        path: "file:///home/safal726/.cache/safalQuick/mode"
        blockLoading: true
        watchChanges: true
    }
    /* reads persisted wallpaper path */
    FileView {
        id: persistFile
        path: "file:///home/safal726/.cache/safalQuick/persist"
        blockLoading: true
        watchChanges: true
        onFileChanged: {
            persistFile.reload();
            persistTimer.restart();
        }
    }

    /* debounces persist file changes */
    Timer {
        id: persistTimer
        interval: 50
        onTriggered: generateColors()
    }

    /* debounces colors.json reload */
    Timer {
        id: reloadTimer
        interval: 100
        onTriggered: {
            jsonFile.reload();
            colorsChanged();
        }
    }

    onIsDarkModeChanged: generateColors()

    Process {
        id: matugenProcess
        onExited: reloadTimer.restart()
    }

    function generateColors() {
        persistFile.reload();
        const path = persistFile.text()?.trim();

        if (!path) {
            return;
        }

        const cleanPath = path.replace("file://", "");
        const mode = isDarkMode ? "dark" : "light";

        matugenProcess.command = ["/bin/sh", "-c", `matugen image "${cleanPath}" -m "${mode}" -t "scheme-fruit-salad"`];
        matugenProcess.running = true;
    }
    Process {
        id: saveModeProcess
    }
    function toggleMode() {
        isDarkMode = !isDarkMode;

        // persist the new mode
        const mode = isDarkMode ? "dark" : "light";
        saveModeProcess.command = ["/bin/sh", "-c", `echo '${mode}' > /home/safal726/.cache/safalQuick/mode`];
        saveModeProcess.running = true;
    }
}
