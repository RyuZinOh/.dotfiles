import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Notifications
import qs.components

PanelWindow {
    id: notifWindow

    // properties
    property string notifAppName: ""
    property string notifSummary: ""
    property string notifBody: ""
    property var notifActions: []
    property var currentNotification: null

    //storing states
    QtObject {
        id: popup
        property bool expanded: false
        property bool hovered: false

        function show() {
            expanded = true;
            hovered = false;
            notifWindow.visible = true;
            autoHideTimer.restart();
            closeT.stop();
        }

        function hide() {
            if (!hovered) {
                expanded = false;
                closeT.start();
            }
        }
        function closeImmediately() {
            expanded = false;
            hovered = false;
            autoHideTimer.stop();
            closeT.stop();
        }
    }

    //showing notifications
    function showNotification(not) {
        currentNotification = not;
        notifAppName = not.appName;
        notifSummary = not.summary;
        notifBody = not.body;
        notifActions = not.actions;
        popup.show();
    }

    Timer {
        id: autoHideTimer
        interval: 3000 //hiding exactly at 3sec auto
        onTriggered: popup.hide()
    }
    Timer {
        id: closeT
        interval: 200 //wait 200 before colapsing the window
        onTriggered: {
            if (!popup.expanded && !popup.hovered) {
                notifWindow.visible = false;
                if (currentNotification) {
                    currentNotification.close();
                    currentNotification = null;
                }
                notifAppName = "";
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

    implicitWidth: 350
    implicitHeight: 120

    //top right corner according to the bar
    margins.top: 40
    anchors.top: true
    anchors.right: true
    margins.right: {
        let scr = Quickshell.screens[0];
        let barW = Math.min(1440, scr.width - 40);
        let barR = (scr.width - barW) / 2;
        return barR + 20;
    }
    PopoutShape {
        id: panel
        anchors.fill: parent
        radius: 10
        color: "black"
        style: 1
        alignment: 0
        clip: true

        height: popup.expanded ? 120 : 0

        transform: Scale {
            origin.x: panel.width / 2
            origin.y: 0
            xScale: 1.0
            yScale: popup.expanded ? 1.0 : 0.0

            Behavior on yScale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
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
            Row {
                anchors.fill: parent
                spacing: 12
                Rectangle {
                    width: 48
                    height: 48
                    radius: 10
                    color: "black"
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: "N"
                        font.family: "CaskaydiaCove NF"
                        font.bold: true
                        font.pixelSize: 20
                        color: "white"
                    }
                }
                Column {
                    width: parent.width - 60 - 32 - 24
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: notifWindow.notifSummary
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                        wrapMode: Text.Wrap
                        width: parent.width
                        maximumLineCount: 1
                        elide: Text.ElideRight
                    }
                    Text {
                        text: notifWindow.notifBody
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 10
                        font.bold: true
                        color: "white"
                        wrapMode: Text.Wrap
                        width: parent.width
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        visible: text !== ""
                    }
                }
                Rectangle {
                    width: 24
                    height: 24
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.pixelSize: 18
                        font.bold: true
                        color: "white"
                    }
                    MouseArea {
                        id: csm
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        z: 100
                        onClicked: popup.closeImmediately()
                    }
                }
            }
        }

        //mouse events -> [on entereing and on clicking and onExiting]
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                popup.hovered = true;
                autoHideTimer.stop();
                closeT.stop();
            }
            onExited: {
                popup.hovered = false;
                autoHideTimer.restart();
            }
            onClicked: {
                if (notifWindow.notifActions && notifWindow.notifActions.length > 0) {
                    notifWindow.notifActions[0].invoke();
                }
                popup.closeImmediately();
            }
        }
    }

    //notification Server
    NotificationServer {
        id: notificationServer
        onNotification: notification => showNotification(notification)
    }
}
