pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Kraken

Singleton {
    id: root
    property string currentWallpaper: ""
    property string displayMode: "wallpaper"
    property string transitionType: "bubble"
    property bool enablePanning: true
    readonly property int bubbleDuration: transitionType === "bubble" ? 1000 : 0
    readonly property string configPath: Quickshell.env("HOME") + "/.cache/safalQuick/wallpaper-config.json"
    property bool loaded: false

    Kraken {
        id: configKraken
        filePath: root.configPath

        onDataLoaded: {
            if (loaded && isObject) {
                if (has("wallpaper")) {
                    root.currentWallpaper = get("wallpaper", "");
                }
                if (has("displayMode")) {
                    root.displayMode = get("displayMode", "wallpaper");
                }
                if (has("transitionType")) {
                    root.transitionType = get("transitionType", "bubble");
                }
                if (has("enablePanning")) {
                    root.enablePanning = get("enablePanning", true);
                }
                root.loaded = true;
            }
        }

        onLoadFailed: error => {
            console.warn("config failed:", error);
            saveConfig();
        }
    }

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        onFileChanged: {
            configKraken.reload();
        }
    }

    IpcHandler {
        target: "wallpaper"

        function setWallpaper(path: string): string {
            const fullPath = path.startsWith("file://") ? path : "file://" + path;
            root.currentWallpaper = fullPath;
            saveConfig();
            return "ok";
        }

        function setMode(mode: string): string {
            if (mode === "wallpaper" || mode === "minimal" || mode === "disabled") {
                root.displayMode = mode;
                if (mode === "minimal" || mode === "disabled") {
                    root.transitionType = "instant";
                    root.enablePanning = false;
                }
                saveConfig();
                return "ok";
            }
            return "invalid mode";
        }

        function setTransition(type: string): string {
            if (root.displayMode !== "wallpaper") {
                return "wallpaper mode only";
            }

            if (type === "bubble" || type === "instant") {
                root.transitionType = type;
                saveConfig();
                return "ok";
            }
            return "invalid transition";
        }

        function setPanning(enabled: string): string {
            if (root.displayMode !== "wallpaper") {
                return "wallpaper mode only";
            }

            root.enablePanning = (enabled === "true" || enabled === "1");
            saveConfig();
            return "ok";
        }

        function getConfig(): string {
            return "wallpaper: " + root.currentWallpaper + "\n" + "mode: " + root.displayMode + "\n" + "transition: " + root.transitionType + "\n" + "panning: " + root.enablePanning;
        }
    }

    function saveConfig() {
        configKraken.set("wallpaper", root.currentWallpaper);
        configKraken.set("displayMode", root.displayMode);
        configKraken.set("transitionType", root.transitionType);
        configKraken.set("enablePanning", root.enablePanning);
        configKraken.save();
    }
}
