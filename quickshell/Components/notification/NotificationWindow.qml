pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Services
import qs.Services.Theme
import qs.utils

Item {
    id: root
    width: 400
    visible: model.count > 0
    height: Math.min(container.height, 1080)

    ListModel {
        id: model
    }

    Rectangle {
        id: container
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 18
        }
        height: column.height
        radius: 16
        color: Theme.surfaceContainerLow
        border.width: 2
        border.color: Theme.outlineVariant
        clip: true

        Column {
            id: column
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            move: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: NotificationConfig.enterSlideDuration
                    easing.type: Easing.OutCubic
                }
            }

            Repeater {
                model: model
                delegate: Item {
                    id: notifItem

                    required property int index
                    required property int notifId
                    required property string summary
                    required property string body
                    required property string appName

                    readonly property string safeSummary: summary || "Notification"
                    readonly property string safeBody: body || ""
                    readonly property string safeAppName: appName || ""
                    readonly property real innerWidth: width - 24
                    readonly property real collapsedBodyHeight: bodyRuler.font.pixelSize * 1.4 * NotificationConfig.collapsedLines
                    readonly property bool isLongText: bodyRuler.implicitHeight > collapsedBodyHeight
                    readonly property bool isActive: index === 0
                    readonly property real fullHeight: content.height + 28

                    property real progress: 0
                    property bool expanded: false
                    property bool entering: true
                    property bool exiting: false

                    width: column.width
                    height: 0
                    x: 480
                    clip: true

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        height: 1
                        color: Theme.outlineVariant
                        opacity: notifItem.index > 0 ? 1 : 0
                        visible: notifItem.index > 0
                    }

                    states: [
                        State {
                            name: "entered"
                            when: !notifItem.entering && !notifItem.exiting
                            PropertyChanges {
                                notifItem.height: notifItem.fullHeight
                                notifItem.x: 0
                            }
                        },
                        State {
                            name: "exiting"
                            when: notifItem.exiting
                            PropertyChanges {
                                notifItem.height: 0
                                notifItem.x: 480
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            from: ""
                            to: "entered"
                            SequentialAnimation {
                                NumberAnimation {
                                    property: "height"
                                    duration: NotificationConfig.enterHeightDuration
                                    easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    property: "x"
                                    duration: NotificationConfig.enterSlideDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                        },
                        Transition {
                            from: "entered"
                            to: "exiting"
                            SequentialAnimation {
                                NumberAnimation {
                                    property: "x"
                                    duration: NotificationConfig.exitSlideDuration
                                    easing.type: Easing.InCubic
                                }
                                NumberAnimation {
                                    property: "height"
                                    duration: NotificationConfig.exitHeightDuration
                                    easing.type: Easing.InCubic
                                }
                                ScriptAction {
                                    script: {
                                        NotificationService.dismiss(notifItem.notifId);
                                        notifItem.exiting = false;
                                    }
                                }
                            }
                        },
                        Transition {
                            from: "entered"
                            to: "entered"
                            NumberAnimation {
                                property: "height"
                                duration: NotificationConfig.expandDuration
                                easing.type: Easing.OutCubic
                            }
                        }
                    ]

                    Text {
                        id: bodyRuler
                        text: notifItem.safeBody
                        width: notifItem.innerWidth
                        font.pixelSize: 13
                        wrapMode: Text.Wrap
                        lineHeight: 1.4
                        visible: false
                        x: -10000
                        y: -10000
                    }
                    Component.onCompleted: Qt.callLater(tryEnter)
                    function tryEnter() {
                        if (notifItem.fullHeight <= 28) {
                            Qt.callLater(tryEnter);
                            return;
                        }
                        notifItem.entering = false;
                        readyTimer.start();
                    }
                    Timer {
                        id: readyTimer
                        interval: NotificationConfig.enterHeightDuration + NotificationConfig.enterSlideDuration
                        onTriggered: NotificationService.onItemEntered()
                    }

                    function dismiss() {
                        if (!notifItem.exiting) {
                            notifItem.exiting = true;
                        }
                    }

                    onIsActiveChanged: {
                        if (isActive) {
                            progress = 0;
                            autoClose.restart();
                        } else {
                            autoClose.stop();
                        }
                    }

                    Timer {
                        id: autoClose
                        interval: NotificationConfig.progressInterval
                        repeat: true
                        running: notifItem.isActive
                        onTriggered: {
                            if (dismissArea.containsMouse || expandArea.containsMouse) {
                                return;
                            }
                            notifItem.progress += NotificationConfig.progressInterval / NotificationConfig.autoCloseDuration;
                            if (notifItem.progress >= 1) {
                                stop();
                                notifItem.dismiss();
                            }
                        }
                    }

                    MouseArea {
                        id: dismissArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.RightButton
                        propagateComposedEvents: true
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                notifItem.dismiss();
                            }
                        }
                    }

                    Column {
                        id: content
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 14
                        }
                        spacing: 10

                        Item {
                            width: content.width
                            height: notifItem.isActive ? 3 : 0
                            clip: true

                            Rectangle {
                                id: progressTrack
                                anchors.fill: parent
                                color: Theme.surfaceContainerHigh
                                radius: 1.5

                                Rectangle {
                                    width: progressTrack.width * notifItem.progress
                                    height: parent.height
                                    color: Theme.primaryColor
                                    radius: 1.5
                                    Behavior on width {
                                        NumberAnimation {
                                            duration: NotificationConfig.progressInterval
                                            easing.type: Easing.Linear
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            width: content.width
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                Layout.alignment: Qt.AlignVCenter
                                radius: 8
                                color: Theme.primaryContainer
                                visible: notifItem.safeAppName !== ""

                                Text {
                                    anchors.centerIn: parent
                                    text: notifItem.safeAppName.charAt(0).toUpperCase()
                                    font {
                                        pixelSize: 18
                                        weight: Font.Bold
                                    }
                                    color: Theme.onPrimaryContainer
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: notifItem.safeAppName
                                font {
                                    pixelSize: 11
                                    weight: Font.Medium
                                }
                                color: Theme.onSurfaceVariant
                                visible: notifItem.safeAppName !== ""
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                Layout.alignment: Qt.AlignVCenter
                                radius: 7
                                color: "transparent"
                                visible: notifItem.isLongText
                                border {
                                    width: 1
                                    color: expandArea.containsMouse ? Theme.primaryColor : Theme.outlineVariant
                                }
                                Behavior on border.color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: notifItem.expanded ? "▲" : "▼"
                                    font.pixelSize: 9
                                    color: expandArea.containsMouse ? Theme.primaryColor : Theme.onSurfaceVariant
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                }

                                MouseArea {
                                    id: expandArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notifItem.expanded = !notifItem.expanded
                                }
                            }
                        }

                        Text {
                            text: notifItem.safeSummary
                            width: content.width
                            font {
                                pixelSize: 14
                                weight: Font.DemiBold
                            }
                            color: Theme.onSurface
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Item {
                            id: bodyContainer
                            width: content.width
                            height: {
                                if (!notifItem.safeBody) {
                                    return 0;
                                }
                                if (notifItem.expanded) {
                                    return bodyRuler.implicitHeight;
                                }
                                if (notifItem.isLongText) {
                                    return notifItem.collapsedBodyHeight;
                                }
                                return bodyRuler.implicitHeight;
                            }
                            clip: true
                            visible: notifItem.safeBody !== ""

                            Behavior on height {
                                NumberAnimation {
                                    duration: NotificationConfig.expandDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                            Text {
                                text: notifItem.safeBody
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
    }

    Connections {
        target: NotificationService
        function onNotificationReady(n) {
            model.insert(0, {
                notifId: n.id,
                summary: n.summary,
                body: n.body,
                appName: n.appName
            });
        }
        function onDismissNotification(id) {
            for (let i = 0; i < model.count; i++) {
                if (model.get(i).notifId === id) {
                    model.remove(i);
                    break;
                }
            }
        }
    }
}
