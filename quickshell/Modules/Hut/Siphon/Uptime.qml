pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.Theme
import qs.Services.Shapes

Item {
    id: root
    implicitWidth: 200
    implicitHeight: 60

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
        border {
            color: Theme.outlineVariant
            width: 1
        }

        Row {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                leftMargin: 14
                rightMargin: 14
            }
            spacing: 20

            Item {
                width: 64
                height: 64
                anchors.verticalCenter: parent.verticalCenter

                ShapeCanvas {
                    anchors.fill: parent
                    roundedPolygon: GetMShapes.get(21)
                    color: Theme.primaryColor
                    imageSource: "file://" + Quickshell.env("HOME") + "/.cache/safalQuick/pfp.jpeg"
                    borderWidth: 2
                    borderColor: Theme.primaryColor
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "uptime"
                    font {
                        family: "CaskaydiaCove NF"
                        pixelSize: 11
                        weight: Font.Medium
                    }
                    color: Theme.onSurfaceVariant
                    opacity: 0.7
                }
                Text {
                    text: root._uptime !== "" ? root._uptime : "—"
                    font {
                        family: "CaskaydiaCove NF"
                        pixelSize: 18
                        weight: Font.Medium
                    }
                    color: Theme.onSurface
                    elide: Text.ElideRight
                }
            }
        }
    }
}
