pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import qs.Services.Paths
import qs.Services.Kraken

Singleton {
    id: root
    property string currentWallpaper: ""
    property string displayMode: "wallpaper"
    property string transitionType: "bubble"
    property bool enablePanning: true
    readonly property int bubbleDuration: transitionType === "bubble" ? 1000 : 0
    readonly property string configPath: PathService.home + "/.cache/safalQuick/wallpaper-config.json"
    property bool loaded: false

    function saveConfig() {
        configKraken.set("wallpaper", root.currentWallpaper.split("/").pop());
        configKraken.set("displayMode", root.displayMode);
        configKraken.set("transitionType", root.transitionType);
        configKraken.set("enablePanning", root.enablePanning);
        configKraken.save();
    }

    Kraken {
        id: configKraken
        filePath: root.configPath
        onDataLoaded: {
            if (configKraken.has("wallpaper")) {
                const saved = configKraken.get("wallpaper", "");
                root.currentWallpaper = saved ? PathService.home + "/Pictures/" + saved : "";
            }
            if (configKraken.has("displayMode"))
                root.displayMode = configKraken.get("displayMode", "wallpaper");
            if (configKraken.has("transitionType"))
                root.transitionType = configKraken.get("transitionType", "bubble");
            if (configKraken.has("enablePanning"))
                root.enablePanning = configKraken.get("enablePanning", true);
            root.loaded = true;
        }
        onLoadFailed: error => {
            console.warn("wallpaper config failed:", error);
            root.saveConfig();
        }
    }
}
