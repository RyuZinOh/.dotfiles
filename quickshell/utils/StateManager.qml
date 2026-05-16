pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import qs.Services.Paths
import qs.Services.Kraken

Singleton {
    id: root

    readonly property string statePath: PathService.state + "/ipcstate.json"
    property bool loaded: false
    signal statesChanged

    function get(key, defaultValue) {
        return loaded ? kraken.get(key, defaultValue) : defaultValue;
    }

    function set(key, value) {
        kraken.set(key, value);
        kraken.save();
        root.statesChanged();
    }

    Kraken {
        id: kraken
        filePath: root.statePath
        onDataLoaded: {
            root.loaded = true;
            root.statesChanged();
        }
        onLoadFailed: _ => {
            root.loaded = true;
            kraken.save();
        }
    }

    Component.onCompleted: kraken.reload()
}
