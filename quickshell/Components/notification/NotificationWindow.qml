pragma ComponentBehavior: Bound
import QtQuick
import qs.Services

Item {
    id: root
    width: 400
    visible: notifColumn.children.length > 0
    height: notifColumn.height

    Column {
        id: notifColumn
        width: parent.width
        spacing: 5
    }

    Connections {
        target: NotificationService

        function onNotificationReceived(notification) {
            var component = Qt.createComponent("NotificationCard.qml");
            if (component.status === Component.Ready) {
                var card = component.createObject(null, {
                    notifId: notification.id,
                    summary: notification.summary || "Notification",
                    body: notification.body || "",
                    appName: notification.appName || ""
                });

                if (card) {
                    var children = [];
                    for (var i = 0; i < notifColumn.children.length; i++) {
                        children.push(notifColumn.children[i]);
                    }
                    card.parent = notifColumn;
                    for (var j = 0; j < children.length; j++) {
                        children[j].parent = null;
                        children[j].parent = notifColumn;
                    }
                }
            }
        }

        function onDismissNotification(id) {
            for (let i = 0; i < notifColumn.children.length; i++) {
                if (notifColumn.children[i].notifId === id) {
                    notifColumn.children[i].destroy();
                    break;
                }
            }
        }
    }
}
