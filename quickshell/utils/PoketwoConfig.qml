pragma Singleton
import QtQuick
import Quickshell
import qs.utils

Singleton {
    id: root

    property bool isActive: false

    signal showPoketwo
    signal hidePoketwo
    signal submitWord(string word)

    Connections {
        target: StateManager

        function onStatesChanged() {
            const newState = StateManager.get("poketwo", false);
            if (root.isActive !== newState) {
                root.isActive = newState;
                if (newState)
                    root.showPoketwo();
                else
                    root.hidePoketwo();
            }
        }
    }
}
