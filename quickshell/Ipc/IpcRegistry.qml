import QtQuick

Item {
    // Component.onCompleted: {
    //     console.log("IPC Registry initialized");
    // }
    //     id: poketwoIpc
    // }

    id: root

    LockIpc {
        id: lockIpc
    }

    ClipsyIpc {
        id: clipsyIpc
    }

    OmnitrixIpc {
        id: omnitrixIpc
    }

    ArtiqaIpc {
        id: artiqaIpc
    }
    // PoketwoIpc {

    DancerIpc {
        id: dancerIpc
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

}
