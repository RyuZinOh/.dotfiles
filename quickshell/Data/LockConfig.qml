pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    signal lockRequested

    // IPC Handler for lockscreen trigger
    IpcHandler {
        target: "lockscreen"

        function lock() {
            console.log("Lock requested via IPC");
            root.lockRequested();
        }
    }
}
