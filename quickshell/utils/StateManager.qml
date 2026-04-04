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

    Component.onCompleted: loadStates()

    function get(key, defaultValue) {
        return loaded ? (states[key] !== undefined ? states[key] : defaultValue) : defaultValue;
    }

    function set(key, value) {
        states[key] = value;
        statesChanged();
        saveStates();
    }

    function loadStates() {
        loadProcess.createObject(root, { running: true });
    }

    property Component loadProcess: Component {
        Process {
            id: loadProc

            property string output: ""
            property var stateRoot: root

            command: ["cat", stateRoot.statePath]
            running: false

            stdout: SplitParser {
                onRead: data => loadProc.output += data
            }

            onRunningChanged: {
                if (!running) {
                    const trimmed = loadProc.output.trim();
                    if (trimmed) {
                        try {
                            stateRoot.states = JSON.parse(trimmed);
                        } catch (e) {
                            console.warn("Failed to parse state JSON:", e);
                            stateRoot.states = {};
                        }
                    }
                    stateRoot.loaded = true;
                    stateRoot.statesChanged();
                    loadProc.destroy();
                }
            }
        }
    }

    function saveStates() {
        const jsonStr = JSON.stringify(states, null, 2);
        const escapedJson = jsonStr.replace(/'/g, "'\\''");
        saveProcess.createObject(root, {
            jsonContent: escapedJson,
            running: true
        });
    }

    property Component saveProcess: Component {
        Process {
            id: saveProc

            property string jsonContent: ""
            property var stateRoot: root

            command: ["bash", "-c", `mkdir -p "$(dirname '${stateRoot.statePath}')" && echo '${jsonContent}' > '${stateRoot.statePath}'`]
            running: false

            stderr: SplitParser {
                onRead: data => {
                    if (data.trim())
                        console.warn("StateManager save error:", data);
                }
            }

            onRunningChanged: {
              if (!running){
                    saveProc.destroy();
              }
            }
        }
    }
}
