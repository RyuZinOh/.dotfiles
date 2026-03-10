pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "wow"

        function toggle(): string {
            if (WowConfig.isActive) {
                WowConfig.isActive = false;
                WowConfig.hideWow();
            } else {
                WowConfig.isActive = true;
                WowConfig.showWow();
            }
            return "wow toggled";
        }

        function activate(): string {
            WowConfig.isActive = true;
            WowConfig.showWow();
            return "wow shown";
        }

        function deactivate(): string {
            WowConfig.isActive = false;
            WowConfig.hideWow();
            return "wow hidden";
        }
    }
}
