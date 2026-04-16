pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "cleave"
        function activate(): string {
            CleaveConfig.activate()
            return "cleave activated"
        }
        function deactivate(): string {
            CleaveConfig.deactivate()
            return "cleave deactivated"
        }
    }
}
