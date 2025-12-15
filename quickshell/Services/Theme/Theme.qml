pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: themeRoot

    property bool isDarkMode: true

    property var colors: {
        try {
            const text = jsonFile.text();
            if (!text || text.trim() === "") {
                return defaultColors;
            }
            const parsed = JSON.parse(text);
            if (parsed.colors && parsed.colors.dark) {
                return parsed.colors[isDarkMode ? "dark" : "light"];
            } else {
                return defaultColors;
            }
        } catch (e) {
            return defaultColors;
        }
    }

    property color backgroundColor: colors.background
    property color surfaceColor: colors.surface
    property color surfaceBright: colors.surface_bright
    property color surfaceContainer: colors.surface_container
    property color primaryColor: colors.primary
    property color primaryContainer: colors.primary_container
    property color secondaryColor: colors.secondary
    property color tertiaryColor: colors.tertiary
    property color onBackground: colors.on_background
    property color onSurface: colors.on_surface
    property color onPrimary: colors.on_primary
    property color accentColor: primaryColor
    property color textColor: onBackground
    property color dimColor: colors.outline

    //watches colors.json
    FileView {
        id: jsonFile
        path: "file:///home/safal726/.cache/safalQuick/colors.json"
        blockLoading: true
        watchChanges: true

        onFileChanged: {
            reloadTimer.restart();
        }
    }

    Timer {
        id: reloadTimer
        interval: 100
        onTriggered: {
            jsonFile.reload();
        }
    }

    function extractFromWallpaper(wallpaperPath) {
        if (!wallpaperPath) {
            return;
        }

        const cleanPath = wallpaperPath.replace("file://", "");
        matugenProcess.command = ["/bin/sh", "-c", `matugen image "${cleanPath}"`];
        matugenProcess.running = true;
    }

    Process {
        id: matugenProcess
    }

    function toggleMode() {
        isDarkMode = !isDarkMode;
    }
}
