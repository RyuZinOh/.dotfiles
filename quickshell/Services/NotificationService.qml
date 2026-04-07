pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Notifications
pragma Singleton

QtObject {
    id: root

    property var queue: []
    property bool processing: false
    property NotificationServer server

    signal notificationReady(var n)
    signal dismissNotification(int id)

    function enqueue(n) {
        queue.push({
            "id": n.id,
            "summary": n.summary || "Notification",
            "body": n.body || "",
            "appName": n.appName || "",
            "image": (typeof n.image === "string" && n.image !== "") ? n.image : ((typeof n.appIcon === "string") ? n.appIcon : ""),
            "appIcon": ""
        });
        if (!processing)
            processNext();

    }

    function processNext() {
        if (queue.length === 0) {
            processing = false;
            return ;
        }
        processing = true;
        root.notificationReady(queue.shift());
    }

    function onItemEntered() {
        Qt.callLater(processNext);
    }

    function dismiss(id) {
        root.dismissNotification(id);
    }

    server: NotificationServer {
        actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true
        onNotification: (n) => {
            return root.enqueue(n);
        }
    }

}
