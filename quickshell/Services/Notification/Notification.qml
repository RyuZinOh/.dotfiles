import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.Services.Shapes

PanelWindow {
    id: notificationWindow

    property string notifSummary: ""
    property string notifBody: ""
    property var notifActions: []
    property var currentNotification: null
    property bool isShowing: false

    anchors {
        right: true
        top: true
    }

    margins {
        right: 0
        top: 10
    }

    implicitWidth: 300

    property int contentHeight: 100
    implicitHeight: isShowing ? contentHeight : 0

    visible: isShowing
    color: "transparent"

    function showNotification(notification) {
        if (!notification) {
            return;
        }

        currentNotification = notification;
        notifSummary = notification.summary || "";
        notifBody = notification.body || "";
        notifActions = notification.actions || [];

        // calculate height based on content
        if (notifBody !== "") {
            contentHeight = 120;
        } else {
            contentHeight = 100;
        }

        isShowing = true;
        notificationCard.scale = 1.0;
        autoHideTimer.restart();
    }

    function hideNotification() {
        notificationCard.scale = 0.0;
        hideDelayTimer.restart();
    }

    Timer {
        id: autoHideTimer
        interval: 4000
        repeat: false
        onTriggered: notificationWindow.hideNotification()
    }

    Timer {
        id: hideDelayTimer
        interval: 300
        repeat: false
        onTriggered: {
            isShowing = false;

            if (currentNotification) {
                currentNotification.close();
                currentNotification = null;
            }

            notifSummary = "";
            notifBody = "";
            notifActions = [];
        }
    }

    PopoutShape {
        id: notificationCard
        anchors.right: parent.right
        anchors.top: parent.top
        implicitWidth: 280
        implicitHeight: notificationWindow.contentHeight
        radius: 20
        color: "black"
        style: 1
        alignment: 2
        clip: true

        transformOrigin: Item.Right
        scale: 0.0

        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                autoHideTimer.stop();
            }

            onExited: {
                autoHideTimer.restart();
            }

            onClicked: {
                autoHideTimer.stop();
                notificationWindow.hideNotification();
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            anchors.leftMargin: 20
            spacing: 6

            Text {
                id: summaryText
                text: notificationWindow.notifSummary
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 14
                font.weight: Font.Bold
                color: "white"
                wrapMode: Text.Wrap
                width: parent.width
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                id: bodyText
                text: notificationWindow.notifBody
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 12
                color: "silver"
                wrapMode: Text.Wrap
                width: parent.width
                maximumLineCount: 3
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 8
            width: 3
            radius: 1.5
            color: "blue"
        }
    }

    NotificationServer {
        id: notificationServer
        onNotification: notification => notificationWindow.showNotification(notification)
    }
}
