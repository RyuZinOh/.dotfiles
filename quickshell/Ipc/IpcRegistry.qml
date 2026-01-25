import QtQuick

Item {
    id: root
    LockIpc {
        id: lockIpc
    }
    WallpaperIpc {
        id: wallpaperIpc
    }

    Component.onCompleted: {
        console.log("IPC Registry initialized");
    }
}
