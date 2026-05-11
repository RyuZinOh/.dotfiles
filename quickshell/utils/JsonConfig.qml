import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string filePath: ""
    property var data: ({})
    property bool loaded: false
    readonly property bool isObject: root.data !== null && typeof root.data === "object" && !Array.isArray(root.data)
    property string _pendingContent: ""

    signal dataLoaded
    signal loadFailed(var error)

    function reload() {
        if (root.filePath)
            fileView.reload();
    }

    function has(key) {
        return root.isObject && Object.prototype.hasOwnProperty.call(root.data, key);
    }

    function get(key, fallback) {
        return root.has(key) ? root.data[key] : fallback;
    }

    function set(key, value) {
        if (!root.isObject)
            root.data = {};
        root.data[key] = value;
        root.dataChanged();
        root.loaded = true;
    }

    function save() {
        if (!root.filePath) {
            root.loadFailed("missing filePath");
            return;
        }

        root._pendingContent = JSON.stringify(root.isObject ? root.data : {}, null, 2);
        if (!mkdirProcess.running)
            mkdirProcess.running = true;
    }

    function _parentDir(path) {
        const idx = path.lastIndexOf("/");
        return idx > 0 ? path.slice(0, idx) : ".";
    }

    function _loadText(text) {
        try {
            root.data = text.trim() ? JSON.parse(text) : {};
            root.loaded = true;
            root.dataLoaded();
        } catch (e) {
            root.data = {};
            root.loaded = false;
            root.loadFailed(e);
        }
    }

    property FileView fileView: FileView {
        id: fileView
        path: root.filePath
        blockLoading: true
        blockWrites: true
        atomicWrites: true
        printErrors: false
        watchChanges: true

        onLoaded: root._loadText(text())
        onLoadFailed: error => {
            root.data = {};
            root.loaded = false;
            root.loadFailed(error);
        }
        onFileChanged: reload()
        onSaveFailed: error => console.warn("JsonConfig save failed:", root.filePath, error)
    }

    property Process mkdirProcess: Process {
        id: mkdirProcess
        command: ["mkdir", "-p", root._parentDir(root.filePath)]
        running: false

        onRunningChanged: {
            if (running || !root._pendingContent)
                return;

            const content = root._pendingContent;
            root._pendingContent = "";
            fileView.setText(content);
        }
    }
}
