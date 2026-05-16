// has formatting issue
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.Services.Theme
import qs.Services.Shapes
import qs.Services.Paths

Item {
    id: root

    property string _uptime: ""
    property bool _ready: false

    function _fmt(raw) {
        const h = raw.match(/(\d+)\s*hour/);
        const m = raw.match(/(\d+)\s*min/);
        const parts = [];
        if (h)
            parts.push(h[1] + "h");
        if (m)
            parts.push(m[1] + "m");
        return parts.join(" ") || raw;
    }

    Component.onCompleted: _proc.running = true

    Process {
        id: _proc
        command: ["bash", "-c", "uptime -p | sed 's/^up //'"]
        property string buf: ""
        stdout: SplitParser {
            onRead: data => _proc.buf += data
        }
        onExited: {
            root._uptime = root._fmt(_proc.buf.trim());
            root._ready = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1

        Item {
            id: pfpItem
            width: 80
            height: 80
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 8
            anchors.bottomMargin: 8

            ShapeCanvas {
                anchors.fill: parent
                roundedPolygon: GetMShapes.get(18)
                color: "transparent"
                imageSource: "file://" + PathService.home + "/.cache/safalQuick/pfp.jpeg"
                borderWidth: 2
                borderColor: Theme.primaryContainer
            }

            Item {
                id: bubble
                width: bubbleRect.width + 24
                height: bubbleRect.height + 16
                anchors.left: pfpItem.right
                anchors.leftMargin: -12
                anchors.bottom: pfpItem.top
                anchors.bottomMargin: -40
                z: 10

                Rectangle {
                    id: bubbleRect
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    width: bubbleText.implicitWidth + 20
                    height: bubbleText.implicitHeight + 12
                    radius: 10
                    color: Theme.surfaceContainerHigh
                    border.color: Theme.outlineVariant
                    border.width: 1

                    Text {
                        id: bubbleText
                        anchors.centerIn: parent
                        text: "ryu"
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: Theme.onSurface
                    }
                }

                Rectangle {
                    width: 7
                    height: 7
                    radius: 4
                    color: Theme.surfaceContainerHigh
                    border.color: Theme.outlineVariant
                    border.width: 1
                    x: 10
                    y: parent.height - 12
                }
            }
        }

        Column {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 8
            anchors.rightMargin: 18
            spacing: 2

            Text {
                anchors.right: parent.right
                text: "uptime"
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.onSurfaceVariant
                opacity: 0.7
            }

            Text {
                anchors.right: parent.right
                text: root._uptime !== "" ? root._uptime : "—"
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Theme.onSurface
                elide: Text.ElideRight
            }
        }
    }
}
