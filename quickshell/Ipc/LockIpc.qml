pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    id: root

    IpcHandler {
        target: "lock"

        function lock(): string {
            LockConfig.lockRequested();
            return "Screen locked";
        }

        function status(): string {
            return "Lock screen ready";
        }
    }
}
