import qs.Components.LockScreen
import qs.Data
import Quickshell.Wayland
import QtQuick

Item {
    Connections {
        target: LockConfig

        function onLockRequested() {
            lock.locked = true;
        }
    }

    LockContext {
        id: lockContext

        onUnlocked: {
            lock.locked = false;
            // Qt.quit(); // why needing it mhm
        }
    }

    WlSessionLock {
        id: lock
        locked: false

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
