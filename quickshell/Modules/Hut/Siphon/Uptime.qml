pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.Services.Theme
import qs.Services.Shapes
import qs.Services.Paths

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
                id: pfpItem
                width: 72
                height: 72
                anchors.verticalCenter: parent.verticalCenter

                ShapeCanvas {
                    anchors.fill: parent
                    roundedPolygon: GetMShapes.get(18)
                    color: Theme.primaryColor
                    imageSource: "file://" + PathService.home + "/.cache/safalQuick/pfp.jpeg"
                    borderWidth: 2
                    borderColor: Theme.primaryColor
                }

                HoverHandler {
                    id: pfpHover
                }

                Item {
                    id: bubble
                    width: bubbleRect.width + 24
                    height: bubbleRect.height + 16
                    x: pfpItem.width - 4
                    y: -height + 25
                    z: 10

                    opacity: pfpHover.hovered ? 1 : 0
                    scale: pfpHover.hovered ? 1 : 0.7
                    transformOrigin: Item.BottomLeft

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutBack
                        }
                    }

                    Rectangle {
                        id: bubbleRect
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        width: bubbleText.implicitWidth + 20
                        height: bubbleText.implicitHeight + 12
                        radius: 10
                        color: Theme.surfaceContainerHigh
                        border {
                            color: Theme.outlineVariant
                            width: 1
                        }

                        Text {
                            id: bubbleText
                            anchors.centerIn: parent
                            text: "proper use of free will.."
                            font {
                                family: "CaskaydiaCove NF"
                                pixelSize: 11
                                weight: Font.Medium
                            }
                            color: Theme.onSurface
                        }
                    }

                    Rectangle {
                        width: 7
                        height: 7
                        radius: 4
                        color: Theme.surfaceContainerHigh
                        border {
                            color: Theme.outlineVariant
                            width: 1
                        }
                        x: 4
                        y: parent.height - 16
                    }

                    Rectangle {
                        width: 5
                        height: 5
                        radius: 3
                        color: Theme.surfaceContainerHigh
                        border {
                            color: Theme.outlineVariant
                            width: 1
                        }
                        x: 0
                        y: parent.height - 8
                    }
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
