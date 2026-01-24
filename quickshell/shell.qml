pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.layers
import qs.utils
import qs.Ipc

ShellRoot {
    Scope {
        IpcRegistry {}
        Hyperixon {}  //  top
        Home {} // background

        LazyLoader {
            id: sessionLockLoader

            component: Component {
                SessionLock {
                    onRequestUnload: {
                        Qt.callLater(() => {
                            sessionLockLoader.active = false;
                        });
                    }
                }
            }
        }

        Connections {
            target: LockConfig
            function onLockRequested() {
                sessionLockLoader.active = true;
            }
        }
    }
}
