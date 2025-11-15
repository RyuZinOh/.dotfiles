import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.Services.Shape

PanelWindow {
    id: notifWindow

    property string notifSummary: ""
    property string notifBody: ""
    property var notifActions: []
    property var currentNotification: null

    QtObject {
        id: popup
        property bool expanded: false
        property bool hovered: false

        function show() {
            expanded = true;
            hovered = false;
            notifWindow.visible = true;
            autoHideTimer.restart();
            closeTimer.stop();
        }

        function hide() {
            if (!hovered) {
                expanded = false;
                closeTimer.start();
            }
        }

        function closeImmediately() {
            expanded = false;
            hovered = false;
            autoHideTimer.stop();
            closeTimer.restart();
        }
    }

    function showNotification(not) {
        currentNotification = not;
        notifSummary = not.summary;
        notifBody = not.body;
        notifActions = not.actions;
        popup.show();
    }

    Timer {
        id: autoHideTimer
        interval: 3000
        onTriggered: popup.hide()
    }

    Timer {
        id: closeTimer
        interval: 220
        onTriggered: {
            if (!popup.expanded && !popup.hovered) {
                notifWindow.visible = false;
                if (currentNotification) {
                    currentNotification.close();
                    currentNotification = null;
                }
                notifSummary = "";
                notifBody = "";
                notifActions = [];
            }
        }
    }

    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    screen: Quickshell.screens[0]

    implicitWidth: 290
    implicitHeight: 100
    margins.top: 35
    anchors.top: true
    anchors.right: true

    PopoutShape {
        id: panel
        anchors.fill: parent
        radius: 25
        color: "black"
        style: 1
        clip: true

        height: popup.expanded ? 120 : 0

        transform: Scale {
            origin.x: panel.width
            origin.y: 0
            yScale: popup.expanded ? 1.0 : 0.0
            Behavior on yScale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InCubic
                }
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 15
            opacity: popup.expanded ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            Column {
                anchors.fill: parent
                spacing: 5

                Text {
                    text: notifWindow.notifSummary
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 16
                    font.bold: true
                    color: "white"
                    wrapMode: Text.Wrap
                    width: parent.width
                    elide: Text.ElideRight
                }

                Text {
                    text: notifWindow.notifBody
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 16
                    color: "gray"
                    wrapMode: Text.Wrap
                    width: parent.width
                    elide: Text.ElideRight
                    visible: text !== ""
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: {
                popup.hovered = true;
                autoHideTimer.stop();
                closeTimer.stop();
            }
            onExited: {
                popup.hovered = false;
                autoHideTimer.restart();
            }
            onClicked: {
                if (notifWindow.notifActions.length > 0) {
                    notifWindow.notifActions[0].invoke();
                }
                popup.closeImmediately();
            }
        }
    }

    NotificationServer {
        id: notificationServer
        onNotification: notification => showNotification(notification)
    }
}
