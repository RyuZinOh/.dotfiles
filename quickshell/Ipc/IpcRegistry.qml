import QtQuick

Item {
    id: root
    LockIpc {
        id: lockIpc
    }
    EvernightIpc {
        id: evernightIpc
    }
    // PoketwoIpc {
    //     id: poketwoIpc
    // }
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
