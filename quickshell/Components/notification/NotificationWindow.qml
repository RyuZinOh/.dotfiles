pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Services
import qs.Services.Theme
import qs.utils

Item {
    id: root

    width: 400
    height: Math.min(column.implicitHeight + 18, 1080)
    visible: notifications.count > 0

    ListModel {
        id: notifications
    }

    Column {
        id: column

        spacing: 8

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Repeater {
            model: notifications

            delegate: NotificationDelegate {
            }

        }

    }

    Connections {
        function onNotificationReady(n) {
            notifications.insert(0, {
                "notifId": n.id,
                "summary": n.summary,
                "body": n.body,
                "appName": n.appName,
                "image": n.image ?? "",
                "appIcon": n.appIcon ?? ""
            });
        }

        function onDismissNotification(id) {
            for (let i = 0; i < notifications.count; i++) {
                if (notifications.get(i).notifId === id) {
                    notifications.remove(i);
                    return ;
                }
            }
        }

        target: NotificationService
    }

    Behavior on height {
        NumberAnimation {
            duration: 320
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.34, 1.06, 0.64, 1, 1, 1]
        }

    }

    component NotificationDelegate: Item {
        id: tile

        required property int index
        required property int notifId
        required property string summary
        required property string body
        required property string appName
        required property string image
        required property string appIcon
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

        function tryEnter() {
            if (naturalHeight <= 28) {
                Qt.callLater(tryEnter);
                return ;
            }
            entering = false;
            readyTimer.start();
        }

        function beginExit() {
            if (!exiting)
                exiting = true;

        }

        width: column.width
        height: animatedHeight
        x: 480
        Component.onCompleted: Qt.callLater(tryEnter)
        onIsTopChanged: {
            if (isTop) {
                tile.progress = 0;
                autoClose.restart();
            } else {
                autoClose.stop();
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

                ParallelAnimation {
                    NumberAnimation {
                        property: "animatedHeight"
                        duration: 420
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.16, 1.1, 0.3, 1, 1, 1]
                    }

                    NumberAnimation {
                        property: "x"
                        duration: 380
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.18, 0.89, 0.32, 1.08, 1, 1]
                    }

                }

            },
            Transition {
                from: "visible"
                to: "exiting"

                SequentialAnimation {
                    NumberAnimation {
                        property: "x"
                        duration: 380
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.68, -0.08, 0.82, 0.1, 1, 1]
                    }

                    NumberAnimation {
                        property: "animatedHeight"
                        duration: 240
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.4, 0, 0.6, 0, 1, 1]
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
                    duration: 320
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 1.02, 0.64, 1, 1, 1]
                }

            }
        ]

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Theme.surfaceContainer

            transform: Scale {
                id: cardScale

                xScale: tile.entering ? 0.96 : 1
                yScale: tile.entering ? 0.96 : 1
                origin.x: tile.width / 2
                origin.y: tile.height / 2

                Behavior on xScale {
                    NumberAnimation {
                        duration: 420
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.16, 1.1, 0.3, 1, 1, 1]
                    }

                }

                Behavior on yScale {
                    NumberAnimation {
                        duration: 420
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.16, 1.1, 0.3, 1, 1, 1]
                    }

                }

            }

        }

        HoverHandler {
            id: hover
        }

        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: tile.beginExit()
        }

        Column {
            id: content

            spacing: 10

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 14
            }

            Item {
                property real targetWidth: width * tile.progress

                width: content.width
                height: tile.isTop ? 10 : 0
                visible: tile.isTop
                clip: true

                Shape {
                    width: parent.targetWidth
                    height: parent.height
                    clip: true
                    layer.enabled: true
                    layer.samples: 8

                    ShapePath {
                        strokeWidth: 2
                        strokeColor: Theme.primaryColor
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin

                        PathSvg {
                            path: {
                                const W = column.width, cy = 5, amp = 3.2, freq = 20;
                                let d = `M 0 ${cy}`;
                                for (let x = 1; x <= W; x += 1) d += ` L ${x} ${cy + amp * Math.sin(x / freq * Math.PI)}`
                                return d;
                            }
                        }

                    }

                }

                Behavior on targetWidth {
                    NumberAnimation {
                        duration: NotificationConfig.progressInterval
                        easing.type: Easing.InOutSine
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
                    visible: tile.image === "" && tile.appIcon === ""

                    Text {
                        anchors.centerIn: parent
                        text: tile.displayApp.charAt(0).toUpperCase()
                        color: Theme.onPrimaryContainer

                        font {
                            pixelSize: 17
                            weight: Font.Bold
                        }

                    }

                }

                Image {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    visible: tile.image !== "" || tile.appIcon !== ""
                    source: tile.image !== "" ? tile.image : tile.appIcon
                    fillMode: Image.PreserveAspectFit
                    layer.enabled: true
                    layer.effect: null
                    layer.smooth: true
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: tile.displayApp
                    color: Theme.onSurfaceVariant

                    font {
                        pixelSize: 11
                        weight: Font.Medium
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    visible: tile.overflows
                    text: "\uedfb"
                    color: expandHover.hovered ? Theme.primaryColor : Theme.onSurfaceVariant
                    rotation: tile.expanded ? 90 : 0

                    font {
                        pixelSize: 11
                        family: "Nerd Font"
                    }

                    HoverHandler {
                        id: expandHover

                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: tile.expanded = !tile.expanded
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 280
                        }

                    }

                    Behavior on rotation {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [0.34, 1.56, 0.64, 1, 1, 1]
                        }

                    }

                }

            }

            Text {
                text: tile.displaySummary
                width: content.width
                color: Theme.onSurface
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight

                font {
                    pixelSize: 14
                    weight: Font.DemiBold
                }

            }

            Item {
                width: content.width
                height: bodyText.implicitHeight
                visible: tile.displayBody !== ""
                clip: true

                Text {
                    id: bodyText

                    text: tile.displayBody
                    width: parent.width
                    font.pixelSize: 13
                    color: Theme.onSurfaceVariant
                    wrapMode: Text.Wrap
                    lineHeight: 1.4
                    maximumLineCount: tile.expanded ? 9999 : NotificationConfig.collapsedLines
                    elide: Text.ElideRight
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 320
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.34, 1.02, 0.64, 1, 1, 1]
                    }

                }

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
                    return ;

                tile.progress += NotificationConfig.progressInterval / NotificationConfig.autoCloseDuration;
                if (tile.progress >= 1) {
                    stop();
                    tile.beginExit();
                }
            }
        }

    }

}
