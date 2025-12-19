pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    signal showOmnitrix
    signal hideOmnitrix

    // IPC Handler for omnitrix control
    IpcHandler {
        target: "omnitrix"

        function activate() {
            root.showOmnitrix();
        }

        function deactivate() {
            root.hideOmnitrix();
        }
    }
}
