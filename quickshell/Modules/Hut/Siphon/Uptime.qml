pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.Services.Theme
import qs.Services.Shapes

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 72

    property string uptime: ""
    property bool ready: false
    property bool hov: false
    property int morphIdx: 8

    Component.onCompleted: proc.running = true

    Timer {
        interval: 600
        running: root.hov
        repeat: true
        onTriggered: root.morphIdx = (root.morphIdx + 1) % 35
    }

    onHovChanged: {
        if (!hov)
            root.morphIdx = 8;
    }

    Process {
        id: proc
        command: ["bash", "-c", "uptime -p | sed 's/^up //'"]
        property string buf: ""
        stdout: SplitParser {
            onRead: data => proc.buf += data
        }
        onExited: {
            root.uptime = proc.buf.trim();
            root.ready = true;
        }
    }

    opacity: root.ready ? 1 : 0
    scale: root.ready ? 1 : 0.95
    Behavior on opacity {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1
    }

    Row {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 14
            rightMargin: 14
        }
        spacing: 12

        Item {
            width: 40
            height: 40
            anchors.verticalCenter: parent.verticalCenter

            ShapeCanvas {
                anchors.fill: parent
                roundedPolygon: GetMShapes.get(root.morphIdx)
                color: Theme.tertiaryColor
                scale: root.hov ? 1.08 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.OutBack
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "\udb82\udd54"
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 20
                color: Theme.surfaceContainer
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: "uptime"
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.onSurfaceVariant
                opacity: 0.75
            }

            Text {
                text: root.uptime !== "" ? root.uptime : "—"
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: Theme.onSurface
                elide: Text.ElideRight
                width: root.implicitWidth - 14 * 2 - 40 - 12
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hov = true
        onExited: root.hov = false
    }
}
