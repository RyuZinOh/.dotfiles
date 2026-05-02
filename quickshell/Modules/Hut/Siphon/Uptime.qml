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
    Component.onCompleted: proc.running = true

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
                roundedPolygon: GetMShapes.get(21)
                color: Theme.primaryContainer
            }

            Text {
                anchors.centerIn: parent
                text: "\udb82\udd54"
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 20
                color: Theme.onPrimaryContainer
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
}
