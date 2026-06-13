pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.Configuration.Chernobyl

Item {
    IpcHandler {
        target: "chernobyl"
        function activate(): string {
            ChernobylConfig.isActive = true;
            ChernobylConfig.showChernobyl();
            return "chernobyl shown";
        }
    }
}
