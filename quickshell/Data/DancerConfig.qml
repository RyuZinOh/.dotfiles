pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    signal showDancer
    signal hideDancer

    // IPC Handler for dancer control
    IpcHandler {
        target: "dancer"

        function activate() {
            root.showDancer();
        }

        function deactivate() {
            root.hideDancer();
        }
    }
}
