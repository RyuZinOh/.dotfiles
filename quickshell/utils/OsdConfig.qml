pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Kraken

Singleton {
    id: root

    property string mode: "volume"
    property int currentValue: 0
    property bool isMuted: false
    property bool isVisible: false

    enum Character {
        Ororon,
        Skirk,
        Chasca
    }

    property int character: OsdConfig.Character.Ororon

    readonly property int maxLimit: 100
    readonly property string configPath: Quickshell.env("HOME") + "/.cache/safalQuick/osd.json"
    property bool loaded: false

    readonly property var characterNames: ["Ororon", "Skirk", "Chasca"]
    readonly property string currentCharacterName: characterNames[character] || "Ororon"

    Kraken {
        id: configKraken
        filePath: root.configPath

        onDataLoaded: {
            if (isObject && has("character")) {
                root.character = get("character", 0);
            }
            root.loaded = true;
        }

        onLoadFailed: error => {
            root.character = OsdConfig.Character.Ororon;
            root.loaded = true;
            saveConfig(); //shitAsss ahh....
        }
    }

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        onFileChanged: {
            if (root.loaded) {
                configKraken.reload();
            }
        }
    }

    Component.onCompleted: {
        configKraken.reload();
    }

    function saveConfig() {
        configKraken.set("character", root.character);
        configKraken.save();
    }
}
