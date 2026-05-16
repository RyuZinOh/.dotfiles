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
    readonly property string configPath: PathService.state + "/wallpaper-config.json"
    readonly property string defaultWallpaper: Qt.resolvedUrl("../Assets/defaults/default_wallpaper.jpeg").toString()
    property bool loaded: false

    function saveConfig() {
        const isDefault = root.currentWallpaper === root.defaultWallpaper;
        configKraken.set("wallpaper", isDefault ? "" : root.currentWallpaper.split("/").pop());
        configKraken.set("displayMode", root.displayMode);
        configKraken.set("transitionType", root.transitionType);
        configKraken.set("enablePanning", root.enablePanning);
        configKraken.save();
    }

    Kraken {
        id: configKraken
        filePath: root.configPath
        onDataLoaded: {
            const saved = configKraken.get("wallpaper", "");
            root.currentWallpaper = saved ? PathService.home + "/Pictures/" + saved : root.defaultWallpaper;
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
            root.currentWallpaper = root.defaultWallpaper;
            root.loaded = true;
        }
    }
}
