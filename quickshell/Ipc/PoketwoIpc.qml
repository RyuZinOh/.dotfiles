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
                PoketwoConfig.hidePoketwo();
            } else {
                PoketwoConfig.isActive = true;
                PoketwoConfig.showPoketwo();
            }
            return "poketwo toggled";
        }

        function activate(): string {
            PoketwoConfig.isActive = true;
            PoketwoConfig.showPoketwo();
            return "poketwo shown";
        }

        function deactivate(): string {
            PoketwoConfig.isActive = false;
            PoketwoConfig.hidePoketwo();
            return "poketwo hidden";
        }
    }
}
