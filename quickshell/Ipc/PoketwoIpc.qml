pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "poketwo"

        function toggle(): string {
            if (PoketwoConfig.isActive) {
                PoketwoConfig.isActive = false;
                StateManager.set("poketwo", false);
                PoketwoConfig.hidePoketwo();
            } else {
                PoketwoConfig.isActive = true;
                StateManager.set("poketwo", true);
                PoketwoConfig.showPoketwo();
            }
            return "poketwo toggled";
        }

        function activate(): string {
            if (!PoketwoConfig.isActive) {
                PoketwoConfig.isActive = true;
                StateManager.set("poketwo", true);
                PoketwoConfig.showPoketwo();
            }
            return "poketwo shown";
        }

        function deactivate(): string {
            if (PoketwoConfig.isActive) {
                PoketwoConfig.isActive = false;
                StateManager.set("poketwo", false);
                PoketwoConfig.hidePoketwo();
            }
            return "poketwo hidden";
        }
    }
}
