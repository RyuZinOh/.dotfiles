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
            console.warn("wallpaper config failed:", error);
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

    function saveConfig() {
        configKraken.set("wallpaper", root.currentWallpaper);
        configKraken.set("displayMode", root.displayMode);
        configKraken.set("transitionType", root.transitionType);
        configKraken.set("enablePanning", root.enablePanning);
        configKraken.save();
    }
}
