import QtQuick
import qs.Services.Shapes

Item {
    id: root
    width: content.width
    height: 220

    property var queue: []
    property int maxVisible: 5
    property real actualHeight: content.height
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
        queueChanged();
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
        queueChanged();
    }

    Connections {
        target: NotificationService
        function onShowNotification(notification) {
            root.addNotification(notification);
        }

        function onHideNotification(id) {
            root.removeCard(id);
        }
    }

    PopoutShape {
        id: content
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        width: queue.length > 0 ? 375 : 0.1
        height: parent.height

        style: 1
        alignment: 2
        radius: 20
        color: NotificationColors.tertiary

        Behavior on width {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 20

            opacity: queue.length > 0 ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            Flickable {
                anchors.fill: parent
                contentHeight: column.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Column {
                    id: column
                    width: parent.width
                    spacing: 9
                }
            }
        }
    }
}
