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
