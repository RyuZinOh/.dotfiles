pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool isActive: false

    signal showOmnitrix
    signal hideOmnitrix

    Connections {
        target: StateManager
        function onStatesChanged() {
            const newState = StateManager.get("omnitrix", false);
            if (root.isActive !== newState) {
                root.isActive = newState;
                if (newState)
                    root.showOmnitrix();
                else
                    root.hideOmnitrix();
            }
        }
    }
 // IPC Handler for omnitrix control
    IpcHandler {
        target: "omnitrix"

        function activate() {
            if (!root.isActive) {
                root.isActive = true;
                StateManager.set("omnitrix", true);
                root.showOmnitrix();
            }
        }

        function deactivate() {
            if (root.isActive) {
                root.isActive = false;
                StateManager.set("omnitrix", false);
                root.hideOmnitrix();
            }
        }
    }
}
