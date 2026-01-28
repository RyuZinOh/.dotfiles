import QtQuick
import Quickshell.Io

QtObject {
    id: root

    function call(target, method) {
        const proc = ipcProcess.createObject(root, {
            target: target,
            method: method,
            running: true
        });
    }

    property Component ipcProcess: Component {
        Process {
            property string target: ""
            property string method: ""

            command: ["quickshell", "ipc", "call", target, method]
            running: false

            //this shit was always ass.
            onExited: (code, status) => {
                destroy();
            }

            function start() {
                running = true;
            }
        }
    }
}
