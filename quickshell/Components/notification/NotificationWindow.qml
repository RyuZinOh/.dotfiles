pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Services
import qs.Services.Theme
import qs.Services.Shapes
import qs.utils

Item {
    id: root

    width: 400
    height: Math.min(container.implicitHeight + 18, 1080)
    visible: notifications.count > 0

    Behavior on height {
        NumberAnimation {
            duration: NotificationConfig.exitHeightDuration
            easing.type: Easing.InCubic
        }
    }

    ListModel {
        id: notifications
    }

    PopoutShape {
        id: container
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        implicitHeight: column.implicitHeight + radius * 2
        alignment: 1
        radius: 16
        color: Theme.surfaceContainerHigh

        Column {
            id: column
            clip: true
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            Repeater {
                model: notifications
                delegate: NotificationDelegate {}
            }
        }
    }

    Connections {
        target: NotificationService

        function onNotificationReady(n) {
            notifications.insert(0, {
                notifId: n.id,
                summary: n.summary,
                body: n.body,
                appName: n.appName
            });
        }

        function onDismissNotification(id) {
            for (let i = 0; i < notifications.count; i++) {
                if (notifications.get(i).notifId === id) {
                    notifications.remove(i);
                    return;
                }
            }
        }
    }

    component NotificationDelegate: Item {
        id: tile

        required property int index
        required property int notifId
        required property string summary
        required property string body
        required property string appName

        readonly property string displaySummary: summary || "Notification"
        readonly property string displayBody: body || ""
        readonly property string displayApp: appName || ""
        readonly property bool isTop: index === 0
        readonly property bool overflows: ruler.implicitHeight > (13 * 1.4 * NotificationConfig.collapsedLines) + 2
        readonly property real naturalHeight: content.implicitHeight + 28

        property bool expanded: false
        property bool entering: true
        property bool exiting: false
        property real progress: 0
        property real animatedHeight: 0

        width: column.width
        height: animatedHeight
        x: 480

        HoverHandler {
            id: hover
        }
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: tile.beginExit()
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
                id: squiggleTrack
                width: content.width
                height: tile.isTop ? 10 : 0
                visible: tile.isTop
                clip: true

                property real targetWidth: squiggleTrack.width * tile.progress

                Behavior on targetWidth {
                    NumberAnimation {
                        duration: NotificationConfig.progressInterval
                        easing.type: Easing.Linear
                    }
                }

                Shape {
                    width: squiggleTrack.targetWidth
                    height: squiggleTrack.height
                    clip: true
                    layer.enabled: true
                    layer.samples: 4

                    ShapePath {
                        strokeWidth: 2.2
                        strokeColor: Theme.primaryColor
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin

                        PathSvg {
                            path: {
                                const W = squiggleTrack.width, cy = squiggleTrack.height / 2;
                                const amp = squiggleTrack.height * 0.38, freq = 12;
                                let d = `M 0 ${cy}`;
                                for (let x = 1; x <= W; x += 2)
                                    d += ` L ${x} ${cy + amp * Math.sin(x / freq * Math.PI)}`;
                                return d;
                            }
                        }
                    }
                }
            }

            RowLayout {
                width: content.width
                spacing: 10
                visible: tile.displayApp !== ""

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    radius: 6
                    color: Theme.primaryContainer

                    Text {
                        anchors.centerIn: parent
                        text: tile.displayApp.charAt(0).toUpperCase()
                        font {
                            pixelSize: 17
                            weight: Font.Bold
                        }
                        color: Theme.onPrimaryContainer
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: tile.displayApp
                    font {
                        pixelSize: 11
                        weight: Font.Medium
                    }
                    color: Theme.onSurfaceVariant
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    visible: tile.overflows
                    text: "\uedfb"
                    font {
                        pixelSize: 11
                        family: "Nerd Font"
                    }
                    color: expandHover.hovered ? Theme.primaryColor : Theme.onSurfaceVariant
                    rotation: tile.expanded ? 90 : 0

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                    Behavior on rotation {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    HoverHandler {
                        id: expandHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: tile.expanded = !tile.expanded
                    }
                }
            }

            Text {
                text: tile.displaySummary
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

            Text {
                text: tile.displayBody
                width: content.width
                visible: tile.displayBody !== ""
                font.pixelSize: 13
                color: Theme.onSurfaceVariant
                wrapMode: Text.Wrap
                lineHeight: 1.4
                maximumLineCount: tile.expanded ? 9999 : NotificationConfig.collapsedLines
                elide: Text.ElideRight
            }
        }

        Text {
            id: ruler
            text: tile.displayBody
            width: tile.width - 28
            font.pixelSize: 13
            wrapMode: Text.Wrap
            lineHeight: 1.4
            visible: false
        }

        Component.onCompleted: Qt.callLater(tryEnter)

        function tryEnter() {
            if (naturalHeight <= 28) {
                Qt.callLater(tryEnter);
                return;
            }
            entering = false;
            readyTimer.start();
        }

        function beginExit() {
            if (!exiting)
                exiting = true;
        }

        onIsTopChanged: {
            if (isTop) {
                tile.progress = 0;
                autoClose.restart();
            } else {
                autoClose.stop();
            }
        }

        Timer {
            id: readyTimer
            interval: NotificationConfig.enterHeightDuration + NotificationConfig.enterSlideDuration
            onTriggered: NotificationService.onItemEntered()
        }

        Timer {
            id: autoClose
            interval: NotificationConfig.progressInterval
            repeat: true
            running: tile.isTop
            onTriggered: {
                if (hover.hovered)
                    return;
                tile.progress += NotificationConfig.progressInterval / NotificationConfig.autoCloseDuration;
                if (tile.progress >= 1) {
                    stop();
                    tile.beginExit();
                }
            }
        }

        states: [
            State {
                name: "entering"
                when: tile.entering && !tile.exiting
                PropertyChanges {
                    tile.animatedHeight: 0
                    tile.x: 480
                }
            },
            State {
                name: "visible"
                when: !tile.entering && !tile.exiting
                PropertyChanges {
                    tile.animatedHeight: tile.naturalHeight
                    tile.x: 0
                }
            },
            State {
                name: "exiting"
                when: tile.exiting
                PropertyChanges {
                    tile.animatedHeight: 0
                    tile.x: 480
                }
            }
        ]

        transitions: [
            Transition {
                from: "entering"
                to: "visible"
                SequentialAnimation {
                    NumberAnimation {
                        property: "animatedHeight"
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
                from: "visible"
                to: "exiting"
                SequentialAnimation {
                    NumberAnimation {
                        property: "x"
                        duration: NotificationConfig.exitSlideDuration
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        property: "animatedHeight"
                        duration: NotificationConfig.exitHeightDuration
                        easing.type: Easing.InCubic
                    }
                    ScriptAction {
                        script: {
                            NotificationService.dismiss(tile.notifId);
                            tile.exiting = false;
                        }
                    }
                }
            },
            Transition {
                from: "visible"
                to: "visible"
                NumberAnimation {
                    property: "animatedHeight"
                    duration: 380
                    easing.type: Easing.OutCubic
                }
            }
        ]
    }
}
