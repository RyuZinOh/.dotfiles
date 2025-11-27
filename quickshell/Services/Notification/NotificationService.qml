pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property var activeNotifications: []

    signal showNotification(notification: var)
    signal hideNotification(id: var)
    signal clearAll

    NotificationServer {
        //enable support for dbus registration [I fucking wasted like 1hr fixed with oh reboot well]
        actionIconsSupported:  true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true

        onNotification: notification => {
            root.activeNotifications.push(notification);
            root.showNotification(notification);
        }
    }

    function dismiss(notificationId) {
        root.hideNotification(notificationId);
        activeNotifications = activeNotifications.filter(n => n.id !== notificationId);
    }

    function dismissAll() {
        activeNotifications.forEach(n => {
            if (n.dismiss)
                n.dismiss();
        });
        activeNotifications = [];
        root.clearAll();
    }
}
