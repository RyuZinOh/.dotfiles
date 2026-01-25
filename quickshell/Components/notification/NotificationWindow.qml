pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Services
import qs.Services.Theme
import qs.utils

Rectangle {
    id: root
    width: 400
    visible: notificationModel.count > 0
    height: Math.min(notifColumn.height + 36, 1080)
    radius: 16
    color: "transparent"
    // border.width: 1
    // border.color: Theme.outlineVariant
    clip: true

    ListModel {
        id: notificationModel
    }

    Column {
        id: notifColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 18
        }
        spacing: 12

        Repeater {
            model: notificationModel
            delegate: Rectangle {
                id: notifItem
                width: notifColumn.width
                height: contentRow.height + 24
                radius: 12
                color: Theme.surfaceContainerLow
                border.width: 2
                border.color: Theme.outlineVariant
                clip: true

                required property int index
                required property int notifId
                required property string summary
                required property string body
                required property string appName

                property bool isActive: index === 0
                property real progress: 0
                property bool expanded: false
                property real dragX: 0
                readonly property bool isLongText: bodyText.implicitHeight > bodyText.font.pixelSize * 3.5

                x: dragX

                Component.onCompleted: {
                    slideInAnim.start();
                }

                onIsActiveChanged: {
                    if (isActive) {
                        progress = 0;
                        autoCloseTimer.restart();
                    } else {
                        autoCloseTimer.stop();
                    }
                }

                Behavior on dragX {
                    enabled: !dragArea.pressed
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                NumberAnimation {
                    id: slideInAnim
                    target: notifItem
                    property: "dragX"
                    from: 600
                    to: 0
                    duration: 550
                    easing.type: Easing.OutCubic
                }

                function dismiss() {
                    hideAnim.start();
                }

                Timer {
                    id: autoCloseTimer
                    interval: 50
                    repeat: true
                    running: notifItem.isActive
                    onTriggered: {
                        if (dragArea.containsMouse || dragArea.pressed || expandCollapseArea.containsMouse) {
                            return;
                        }
                        notifItem.progress += 50 / NotificationConfig.autoCloseDuration;

                        if (notifItem.progress >= 1) {
                            autoCloseTimer.stop();
                            notifItem.dismiss();
                        }
                    }
                }

                NumberAnimation {
                    id: hideAnim
                    target: notifItem
                    property: "dragX"
                    to: 700
                    duration: 550
                    easing.type: Easing.OutCubic
                    onFinished: {
                        NotificationService.dismiss(notifItem.notifId);
                        for (let i = 0; i < notificationModel.count; i++) {
                            if (notificationModel.get(i).notifId === notifItem.notifId) {
                                notificationModel.remove(i);
                                break;
                            }
                        }
                    }
                }

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: dragArea.containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    propagateComposedEvents: true

                    property real startX: 0

                    onPressed: mouse => {
                        startX = mouse.x;
                    }

                    onPositionChanged: mouse => {
                        if (pressed) {
                            var delta = mouse.x - startX;
                            if (delta > 0) {
                                notifItem.dragX = Math.min(delta, 700);
                            }
                        }
                    }

                    onReleased: mouse => {
                        if (Math.abs(notifItem.dragX) > 100)
                            notifItem.dismiss();
                        else
                            notifItem.dragX = 0;
                    }

                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            notifItem.dismiss();
                    }
                }

                Column {
                    id: contentRow
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 12
                    }
                    spacing: 12

                    Rectangle {
                        id: progressBar
                        width: contentRow.width
                        height: 3
                        color: Theme.surfaceContainerHigh
                        radius: 1.5
                        visible: notifItem.isActive

                        Rectangle {
                            width: progressBar.width * notifItem.progress
                            height: progressBar.height
                            color: Theme.primaryColor
                            radius: 1.5
                            Behavior on width {
                                NumberAnimation {
                                    duration: 50
                                    easing.type: Easing.Linear
                                }
                            }
                        }
                    }

                    Row {
                        id: headerRow
                        width: contentRow.width
                        spacing: 12

                        Rectangle {
                            id: iconRect
                            width: 44
                            height: 44
                            radius: 10
                            color: Theme.primaryContainer
                            visible: notifItem.appName

                            Text {
                                anchors.centerIn: iconRect
                                text: notifItem.appName ? notifItem.appName.charAt(0).toUpperCase() : ""
                                font {
                                    pixelSize: 22
                                    weight: Font.Bold
                                }
                                color: Theme.onPrimaryContainer
                            }
                        }

                        Column {
                            anchors.verticalCenter: headerRow.verticalCenter
                            spacing: 2
                            width: contentRow.width - iconRect.width - 12 - (notifItem.isLongText ? expandCollapseButton.width + 24 : 0)

                            Text {
                                text: notifItem.appName
                                font {
                                    pixelSize: 11
                                    weight: Font.Medium
                                }
                                color: Theme.onSurfaceVariant
                                visible: notifItem.appName
                            }
                        }

                        Item {
                            width: notifItem.isLongText ? 4 : 1
                            height: 1
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            id: expandCollapseButton
                            width: 30
                            height: 30
                            radius: 8
                            color: "transparent"
                            border.width: 1
                            border.color: expandCollapseArea.containsMouse ? Theme.primaryColor : Theme.outlineVariant
                            visible: notifItem.isLongText
                            anchors.verticalCenter: headerRow.verticalCenter

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }

                            Text {
                                anchors.centerIn: expandCollapseButton
                                text: notifItem.expanded ? "▲" : "▼"
                                font.pixelSize: 10
                                color: expandCollapseArea.containsMouse ? Theme.primaryColor : Theme.onSurfaceVariant

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }
                            }

                            MouseArea {
                                id: expandCollapseArea
                                anchors.fill: expandCollapseButton
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notifItem.expanded = !notifItem.expanded
                            }
                        }
                    }

                    Text {
                        id: summaryText
                        text: notifItem.summary
                        width: contentRow.width
                        font {
                            pixelSize: 15
                            weight: Font.DemiBold
                        }
                        color: Theme.onSurface
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Item {
                        id: bodyContainer
                        width: contentRow.width
                        height: notifItem.expanded ? bodyText.height : (notifItem.isLongText ? bodyText.font.pixelSize * 3 : bodyText.height)
                        clip: true
                        visible: notifItem.body

                        Behavior on height {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            id: bodyText
                            text: notifItem.body
                            width: bodyContainer.width
                            font.pixelSize: 13
                            color: Theme.onSurfaceVariant
                            wrapMode: Text.Wrap
                            lineHeight: 1.4
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: NotificationService

        function onNotificationReceived(notification) {
            notificationModel.insert(0, {
                notifId: notification.id,
                summary: notification.summary || "Notification",
                body: notification.body || "",
                appName: notification.appName || ""
            });
        }

        function onDismissNotification(id) {
            for (let i = 0; i < notificationModel.count; i++) {
                if (notificationModel.get(i).notifId === id) {
                    notificationModel.remove(i);
                    break;
                }
            }
        }
    }
}
