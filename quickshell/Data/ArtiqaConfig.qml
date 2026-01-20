pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isActive: false

    signal showArtiqa
    signal hideArtiqa

    Connections {
        target: StateManager
        function onStatesChanged() {
            const newState = StateManager.get("artiqa", false);
            if (root.isActive !== newState) {
                root.isActive = newState;
                if (newState)
                    root.showArtiqa();
                else
                    root.hideArtiqa();
            }
        }
    }

    // IPC Handler for artiqa control
    IpcHandler {
        target: "artiqa"

        function activate() {
            if (!root.isActive) {
                root.isActive = true;
                StateManager.set("artiqa", true);
                root.showArtiqa();
            }
        }

        function deactivate() {
            if (root.isActive) {
                root.isActive = false;
                StateManager.set("artiqa", false);
                root.hideArtiqa();
            }
        }

        function toggle() {
            if (root.isActive) {
                deactivate();
            } else {
                activate();
            }
        }
    }
}
