import QtQuick
import Quickshell.Io

QtObject {
    id: root
    property string filePath: ""
    signal dataLoaded
    signal loadFailed(string error)
    function get(key, fallback) {
        const v = _store[key];
        return (v !== undefined && v !== null) ? v : (fallback ?? null);
    }

    function has(key) {
        return Object.prototype.hasOwnProperty.call(_store, key);
    }

    function set(key, value) {
        _store[key] = value;
    }
    function save() {
        _view.setText(JSON.stringify(_store, null, 2));
    }
    function reload() {
        _view.reload();
    }

    property var _store: ({})
    readonly property var data: _store
    property var _view: FileView {
        path: root.filePath
        watchChanges: true

        onFileChanged: reload()

        onLoaded: {
            try {
                const parsed = JSON.parse(text());
                if (parsed && typeof parsed === "object") {
                    root._store = parsed;
                    root.dataLoaded();
                } else {
                    root.loadFailed("JSON object required");
                }
            } catch (e) {
                root.loadFailed(String(e));
            }
        }
        onLoadFailed: err => {
            const msg = err === 2 ? "File does not exist" : ("FileViewError(" + err + ")");
            root.loadFailed(msg);
        }
    }
}
