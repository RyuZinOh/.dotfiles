pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configPath: "/home/safal726/.cache/safalQuick/ash/ashconfig.json"

    signal setWidth(int width)
    signal setMode(string mode)
    signal reset
    signal configLoaded(int width, string mode)

    property string currentMode: "circle"

    Component.onCompleted: {
        loadConfigFromFile();
    }

    function saveConfig(width, mode) {
        var config = {
            width: width,
            mode: mode
        };
        var json = JSON.stringify(config, null, 2);
        saveProcess.command = ["sh", "-c", "echo '" + json + "' > " + configPath];
        saveProcess.running = true;
    }

    function loadConfigFromFile() {
        if (loadProcess.running)
            return;
        loadProcessOutput = "";
        loadProcess.running = true;
    }

    property string loadProcessOutput: ""

    Process {
        id: saveProcess
        running: false
    }

    Process {
        id: loadProcess
        command: ["cat", root.configPath]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.loadProcessOutput += data;
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                try {
                    var output = root.loadProcessOutput.trim();
                    if (!output) {
                        root.configLoaded(-1, "circle");
                        return;
                    }
                    var config = JSON.parse(output);
                    var w = (config.width !== undefined && config.width > 0) ? config.width : -1;
                    var m = config.mode || "circle";

                    var validModes = ["circle", "bar", "notch"];
                    if (validModes.indexOf(m) === -1) {
                        console.log("Error: Mode '" + m + "' from config doesn't exist. Available modes are: circle, bar, notch. Defaulting to 'circle'.");
                        m = "circle";
                    }

                    root.currentMode = m;
                    root.configLoaded(w, m);
                } catch (e) {
                    root.configLoaded(-1, "circle");
                }
            } else {
                root.configLoaded(-1, "circle");
            }
            root.loadProcessOutput = "";
        }
    }

    IpcHandler {
        target: "ash"

        function setWidth(width: int) {
            if (root.currentMode !== "bar" && root.currentMode !== "notch") {
                console.log("Error: Width can only be set for 'bar' and 'notch' modes. Current mode is '" + root.currentMode + "'");
                return;
            }
            root.setWidth(width);
        }

        function setMode(mode: string) {
            var validModes = ["circle", "bar", "notch"];
            if (validModes.indexOf(mode) === -1) {
                console.log("Error: Mode '" + mode + "' doesn't exist. Available modes are: circle, bar, notch");
                return;
            }
            root.setMode(mode);
        }

        function reset() {
            root.reset();
        }
    }
}
