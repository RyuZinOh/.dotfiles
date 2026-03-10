import QtQuick

Item {
    id: root
    LockIpc {
        id: lockIpc
    }
    WowIpc {
        id: wowIpc
    }
    WallpaperIpc {
        id: wallpaperIpc
    }
    OsdIpc {
        id: osdIpc
    }
    Component.onCompleted: {
        console.log("IPC Registry initialized");
    }
}
