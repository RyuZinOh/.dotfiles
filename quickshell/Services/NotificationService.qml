pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    signal notificationReceived(notification: var)
    signal dismissNotification(id: var)

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

        onNotification: notification => {
            root.notificationReceived(notification);
        }
    }

    function dismiss(notificationId) {
        root.dismissNotification(notificationId);
    }
}
