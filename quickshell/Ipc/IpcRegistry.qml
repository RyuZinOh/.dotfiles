import QtQuick

Item {
    id: root
    LockIpc {
        id: lockIpc
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
