import QtQuick

Item {
    id: root
    LockIpc {
        id: lockIpc
    }
    Component.onCompleted: {
        console.log("IPC Registry initialized");
    }
}
