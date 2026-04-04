pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "omnitrix"

        function toggle(): string {
            if (OmnitrixConfig.isActive) {
                OmnitrixConfig.isActive = false;
                StateManager.set("omnitrix", false);
                OmnitrixConfig.hideOmnitrix();
            } else {
                OmnitrixConfig.isActive = true;
                StateManager.set("omnitrix", true);
                OmnitrixConfig.showOmnitrix();
            }
            return "omnitrix toggled";
        }

        function activate(): string {
            if (!OmnitrixConfig.isActive) {
                OmnitrixConfig.isActive = true;
                StateManager.set("omnitrix", true);
                OmnitrixConfig.showOmnitrix();
            }
            return "omnitrix shown";
        }

        function deactivate(): string {
            if (OmnitrixConfig.isActive) {
                OmnitrixConfig.isActive = false;
                StateManager.set("omnitrix", false);
                OmnitrixConfig.hideOmnitrix();
            }
            return "omnitrix hidden";
        }
    }
}
