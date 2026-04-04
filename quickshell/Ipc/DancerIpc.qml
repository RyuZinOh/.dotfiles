pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "dancer"

        function toggle(): string {
            if (DancerConfig.isActive) {
                DancerConfig.isActive = false;
                StateManager.set("dancer", false);
                DancerConfig.hideDancer();
            } else {
                DancerConfig.isActive = true;
                StateManager.set("dancer", true);
                DancerConfig.showDancer();
            }
            return "dancer toggled";
        }

        function activate(): string {
            if (!DancerConfig.isActive) {
                DancerConfig.isActive = true;
                StateManager.set("dancer", true);
                DancerConfig.showDancer();
            }
            return "dancer shown";
        }

        function deactivate(): string {
            if (DancerConfig.isActive) {
                DancerConfig.isActive = false;
                StateManager.set("dancer", false);
                DancerConfig.hideDancer();
            }
            return "dancer hidden";
        }
    }
}
