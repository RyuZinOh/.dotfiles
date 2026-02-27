pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    signal notificationReady(var n)
    signal dismissNotification(int id)

    property var queue: []
    property bool processing: false

    property NotificationServer server: NotificationServer {
        actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true
        onNotification: n => root.enqueue(n)
    }

    function enqueue(n) {
        queue.push({
            id: n.id,
            summary: n.summary || "Notification",
            body: n.body || "",
            appName: n.appName || ""
        });
        if (!processing) {
            processNext();
        }
    }

    function processNext() {
        if (queue.length === 0) {
            processing = false;
            return;
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
}
