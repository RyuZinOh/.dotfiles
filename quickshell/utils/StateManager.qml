pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string statePath: Quickshell.env("HOME") + "/.cache/safalQuick/ipcstate.json"
    property var states: ({})
    property bool loaded: false
    Component.onCompleted: {
        loadStates();
    }
    function get(key, defaultValue) {
        return loaded ? (states[key] !== undefined ? states[key] : defaultValue) : defaultValue;
    }
    function set(key, value) {
        states[key] = value;
        statesChanged();
        saveStates();
    }
    function loadStates() {
        const proc = loadProcess.createObject(root);
        proc.start();
    }

    property Component loadProcess: Component {
        Process {
            command: ["cat", root.statePath]
            running: false
            property string output: ""

            stdout: SplitParser {
                onRead: data => output += data
            }

            onExited: (code, status) => {
                if (code === 0) {
                    const trimmed = output.trim();
                    if (trimmed) {
                        try {
                            root.states = JSON.parse(trimmed);
                        } catch (e) {
                            console.warn("Failed to parse state JSON:", e);
                            root.states = {};
                        }
                    }
                }
                root.loaded = true;
                root.statesChanged();
                destroy();
            }

            function start() {
                running = true;
            }
        }
    }
    function saveStates() {
        const jsonStr = JSON.stringify(states, null, 2);
        const escapedJson = jsonStr.replace(/'/g, "'\\''");

        const proc = saveProcess.createObject(root, {
            jsonContent: escapedJson
        });
        proc.start();
    }

    property Component saveProcess: Component {
        Process {
            property string jsonContent: ""
            command: ["bash", "-c", `mkdir -p "$(dirname '${root.statePath}')" && echo '${jsonContent}' > '${root.statePath}'`]
            running: false

            stderr: SplitParser {
                onRead: data => {
                    if (data.trim()) {
                        console.warn("StateManager save error:", data);
                    }
                }
            }

            onExited: (code, status) => {
                destroy();
            }
            function start() {
                running = true;
            }
        }
    }
}
