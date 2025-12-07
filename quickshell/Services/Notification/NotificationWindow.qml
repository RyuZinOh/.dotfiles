import Quickshell
import QtQuick
import qs.Services.Shapes

PanelWindow {
    id: window
    property var queue: []
    property int maxVisible: 5
    anchors {
        right: true
        top: true
    }
    margins {
        right: 0
        top: 0
    }
    implicitWidth: 360
    implicitHeight: column.height + 32
    visible: column.children.length > 0
    color: "transparent"

    //addin' notifications
    function addNotification(notification) {
        if (!notification) {
            return;
        }
        if (queue.length >= maxVisible) {
            var oldest = queue.shift();
            removeCard(oldest.id);
        }
        var data = {
            id: notification.id || Date.now(),
            summary: notification.summary || "Notification",
            body: notification.body || "",
            appName: notification.appName || "",
            appIcon: notification.appIcon || notification.icon || "",
            actions: notification.actions || [],
            notification: notification
        };
        queue.push(data);
        createCard(data);
    }

    //creating cards here
    function createCard(data) {
        var component = Qt.createComponent("NotificationCard.qml");

        if (component.status !== Component.Ready) {
            return;
        }
        var card = component.createObject(column, {
            notifId: data.id,
            summary: data.summary,
            body: data.body,
            appName: data.appName,
            appIcon: data.appIcon,
            actions: data.actions
        });
        if (!card) {
            console.log("Failed to create notification card");
            return;
        }
        card.dismissed.connect(() => {
            removeCard(data.id);
            if (data.notification?.dismiss) {
                data.notification.dismiss();
            }
            NotificationService.dismiss(data.id);
        });
        card.actionInvoked.connect(actionId => {
            if (data.notification?.invokeAction) {
                data.notification.invokeAction(actionId);
            }
            removeCard(data.id);
        });

        card.parent = column;

        //index 0 as to show priority
        var childCount = column.children.length;
        for (var i = 0; i < childCount - 1; i++) {
            var child = column.children[0];
            if (child !== card) {
                child.parent = null;
                child.parent = column;
            }
        }
    }

    function removeCard(id) {
        for (var i = 0; i < column.children.length; i++) {
            if (column.children[i].notifId === id) {
                column.children[i].destroy();
                break;
            }
        }
        queue = queue.filter(n => n.id !== id);
    }

    Connections {
        target: NotificationService
        function onShowNotification(notification) {
            window.addNotification(notification);
        }

        function onHideNotification(id) {
            window.removeCard(id);
        }
    }

    Rectangle {
        id: backgroundShape
        width: parent.width
        height: parent.height
        // style: 1
        // alignment: 2
        // radius: 12
        color: NotificationColors.tertiary

        Column {
            id: column
            width: parent.width
            spacing: 9
        }
    }
}
