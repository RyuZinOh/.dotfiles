import QtQuick
import Quickshell
import qs.utils
pragma Singleton

Singleton {
    id: root

    property bool isActive: false

    signal showOmnitrix()
    signal hideOmnitrix()

    Connections {
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

        target: StateManager
    }

}
