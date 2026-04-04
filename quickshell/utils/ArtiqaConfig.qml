import QtQuick
import Quickshell
import qs.utils
pragma Singleton

Singleton {
    id: root

    property bool isActive: false

    signal showArtiqa()
    signal hideArtiqa()

    Connections {
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

        target: StateManager
    }

}
