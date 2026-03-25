pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "evernight"

        function toggle(): string {
            if (EvernightConfig.isActive) {
                EvernightConfig.isActive = false;
                EvernightConfig.hideEvernight();
            } else {
                EvernightConfig.isActive = true;
                EvernightConfig.showEvernight();
            }
            return "evernight toggled";
        }

        function activate(): string {
            EvernightConfig.isActive = true;
            EvernightConfig.showEvernight();
            return "evernight shown";
        }

        function deactivate(): string {
            EvernightConfig.isActive = false;
            EvernightConfig.hideEvernight();
            return "evernight hidden";
        }
    }
}
