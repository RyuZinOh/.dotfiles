import QtQuick
import Quickshell
import qs.utils
pragma Singleton

Singleton {
    id: root

    property bool isActive: false

    signal showDancer()
    signal hideDancer()

    Connections {
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

        target: StateManager
    }

}
