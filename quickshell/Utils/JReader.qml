import QtQuick
import Quickshell.Io

QtObject {
    id: adapter
    property string filePath: ""
    property var data: ({})
    property bool loaded: false
    property bool loading: false

    signal dataLoaded
    signal loadFailed(string error)

    Component.onCompleted: filePath && load()
    onFilePathChanged: filePath && !loading && load()

    function load() {
        if (!filePath) {
            loadFailed("No file path specified");
            return;
        }
        loading = true;
        loaded = false;
        processComponent.createObject(adapter).start();
    }
    property Component processComponent: Component {
        Process {
            id: proc
            command: ["cat", adapter.filePath]
            running: false
            property string output: ""
            stdout: SplitParser {
                onRead: data => proc.output += data
            }
            onExited: (code, status) => {
                adapter.loading = false;
                if (code === 0) {
                    const trimmed = proc.output.trim();
                    if (!trimmed) {
                        adapter.loadFailed("File is empty");
                    } else {
                        try {
                            adapter.data = JSON.parse(trimmed);
                            adapter.loaded = true;
                            adapter.dataLoaded();
                        } catch (e) {
                            adapter.loadFailed("Invalid JSON: " + e);
                        }
                    }
                } else {
                    adapter.loadFailed("File not found or cannot be read");
                }
                destroy();
            }

            function start() {
                running = true;
            }
        }
    }
}
