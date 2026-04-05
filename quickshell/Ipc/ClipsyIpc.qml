pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "clipsy"
        function activate(): string {
            ClipsyConfig.isActive = true;
            ClipsyConfig.showClipsy();
            return "clipsy shown";
        }
    }
}
