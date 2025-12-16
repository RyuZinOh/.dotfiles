import QtQuick
import qs.Services.Shapes
import qs.Services.Theme

Item {
    id: root
    width: content.width
    height: content.height

    property var queue: []
    property int maxVisible: 5
    property real actualHeight: content.height

    //update active card whenever queue changes
    function updateActiveCard() {
        for (var i = 0; i < column.children.length; i++) {
            var child = column.children[i];
            if (child && child.notifId !== undefined) {
                //first card (index => 0) is active, others are not
                child.isActiveCard = (i === 0);
            }
        }
    }

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
            actions: data.actions,
            isActiveCard: false // activation
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
        Qt.callLater(updateActiveCard);
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
        Qt.callLater(updateActiveCard);
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
        anchors.top: parent.top

        width: 420
        height: queue.length > 0 ? Math.min(column.implicitHeight + 60, 800) : 0
        style: 1
        alignment: 1
        radius: queue.length > 0 ? 20 : 5
        color: Theme.surfaceContainer

        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutCubic
            }
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            anchors.rightMargin: 0

            opacity: queue.length > 0 ? 1 : 0
            visible: opacity > 0
            scale: queue.length > 0 ? 1 : 0.95

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            Flickable {
                id: flickable
                anchors.fill: parent
                contentHeight: column.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                interactive: !anyCardDragging()

                function anyCardDragging() {
                    for (var i = 0; i < column.children.length; i++) {
                        var child = column.children[i];
                        if (child && child.isDragging !== undefined && child.isDragging) {
                            return true;
                        }
                    }
                    return false;
                }

                Column {
                    id: column
                    width: parent.width
                    spacing: 9
                }
            }
        }
    }
}
