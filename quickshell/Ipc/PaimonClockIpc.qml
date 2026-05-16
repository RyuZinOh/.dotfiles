pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "paimonclock"

        function toggle(): string {
            PaimonClockConfig.toggle();
            return "paimonclock toggled";
        }

        function activate(): string {
            if (!PaimonClockConfig.isActive)
                PaimonClockConfig.show();
            return "paimonclock shown";
        }

        function deactivate(): string {
            if (PaimonClockConfig.isActive)
                PaimonClockConfig.hide();
            return "paimonclock hidden";
        }

        function randomize(): string {
            PaimonClockConfig.randomizePosition();
            return "paimonclock position randomized to " + PaimonClockConfig.clockX + "," + PaimonClockConfig.clockY;
        }
    }
}
