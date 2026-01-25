pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Wayland

Item {
    id: root

    signal requestUnload

    Component.onCompleted: {
        lock.locked = true;
    }

    LockContext {
        id: lockContext
        onUnlocked: {
            lock.locked = false;
            root.requestUnload();
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
