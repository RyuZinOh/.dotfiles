pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool isActive: false

    signal showDancer
    signal hideDancer

    Connections {
        target: StateManager
        function onStatesChanged() {
            const newState = StateManager.get("dancer", false);
            if (root.isActive !== newState) {
                root.isActive = newState;
                if (newState)
                    root.showDancer();
                else
                    root.hideDancer();
            }
        }
    }
 // IPC Handler for dancer control
    IpcHandler {
        target: "dancer"

        function activate() {
            if (!root.isActive) {
                root.isActive = true;
                StateManager.set("dancer", true);
                root.showDancer();
            }
        }

        function deactivate() {
            if (root.isActive) {
                root.isActive = false;
                StateManager.set("dancer", false);
                root.hideDancer();
            }
        }
    }
}
