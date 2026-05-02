pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import Quickshell.Widgets
import qs.Services.Theme
import qs.Services.Shapes
import qs.utils

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 200

    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: 52 * 2 + 4 + 12
        radius: 22
        color: Theme.surfaceContainer
        border {
            color: Theme.outlineVariant
            width: 1
        }
    }

    Row {
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 6
        }
        spacing: 4

        MediaSlider {
            width: 52
            height: parent.height
            value: Math.round(OsdConfig.sinkVolume)
            muted: OsdConfig.sinkMuted
            accentFill: Theme.inversePrimary
            accentOnFill: Theme.onPrimaryContainer
            trackFill: Theme.primaryContainer
            icons: ["\uf026", "\uf027", "\uf027", "\uf028"]
            onScrub: delta => OsdConfig.adjustVolume(delta > 0 ? "2%+" : "2%-")
        }

        MediaSlider {
            id: brightSlider
            width: 52
            height: parent.height
            value: brightnessVal
            accentFill: "red"
            accentOnFill: Theme.onPrimaryContainer
            trackFill: Theme.primaryContainer
            icons: ["", "\udb80\udcde", "\udb80\udcdd", "\udb80\udce0"]
            onScrub: delta => {
                brightnessVal = Math.max(0, Math.min(100, brightnessVal + delta));
                OsdConfig.adjustBrightness(delta > 0 ? "2%+" : "2%-");
            }

            property int brightnessVal: 50

            Connections {
                target: OsdConfig
                function onCurrentValueChanged() {
                    if (OsdConfig.mode === "brightness")
                        brightSlider.brightnessVal = OsdConfig.currentValue;
                }
            }

            Process {
                command: ["sh", "-c", "brightnessctl -m | awk -F, '{print substr($4, 1, length($4)-1)}'"]
                stdout: StdioCollector {
                    onStreamFinished: brightSlider.brightnessVal = Math.round(parseFloat(text.trim()))
                }
                running: true
            }
        }
    }

    Item {
        width: 48
        height: 48
        anchors {
            left: parent.left
            bottom: parent.bottom
        }

        ShapeCanvas {
            anchors.fill: parent
            roundedPolygon: GetMShapes.get(2)
            color: OsdConfig.sinkMuted ? Theme.errorContainer : Theme.primaryContainer
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: OsdConfig.sinkMuted ? "\uf026" : "\uf027"
            font {
                family: "CaskaydiaCove NF"
                pixelSize: 15
            }
            color: OsdConfig.sinkMuted ? Theme.onErrorContainer : Theme.onPrimaryContainer
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: OsdConfig.toggleMute()
        }
    }

    component MediaSlider: Item {
        id: ms

        required property real value
        required property var icons
        property bool muted: false
        required property color accentFill
        required property color accentOnFill
        required property color trackFill

        signal scrub(int delta)

        readonly property real fillFrac: muted ? 0 : value / 100
        readonly property string currentIcon: {
            if (muted && icons[0])
                return icons[0];
            if (value >= 66)
                return icons[3];
            if (value >= 33)
                return icons[2];
            return icons[1];
        }

        ClippingRectangle {
            id: track
            anchors.centerIn: parent
            width: 45
            height: ms.height
            radius: 18
            color: Theme.surfaceContainer
            border {
                width: 1
                color: Theme.outlineVariant
            }

            Rectangle {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                height: track.height * ms.fillFrac
                color: ms.trackFill
                Behavior on height {
                    NumberAnimation {
                        duration: 80
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: Math.min(track.height - 28, track.height - track.height * ms.fillFrac + 6)
                text: ms.currentIcon
                font {
                    family: "CaskaydiaCove NF"
                    pixelSize: 16
                }
                color: ms.fillFrac > 0.15 ? ms.accentOnFill : Theme.onSurfaceVariant
                Behavior on color {
                    ColorAnimation {
                        duration: 80
                    }
                }
                Behavior on y {
                    NumberAnimation {
                        duration: 80
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                property real startY: 0
                property real startVal: 0

                onPressed: e => {
                    startY = e.y;
                    startVal = ms.value;
                }
                onPositionChanged: e => {
                    const delta = Math.round((startY - e.y) / ms.height * 100);
                    const newVal = Math.max(0, Math.min(100, Math.round(startVal + delta)));
                    if (newVal !== ms.value)
                        ms.scrub(newVal > ms.value ? 2 : -2);
                    startY = e.y;
                    startVal = ms.value;
                }
                onWheel: w => {
                    const d = w.angleDelta.y !== 0 ? w.angleDelta.y : -w.angleDelta.x;
                    ms.scrub(d > 0 ? 2 : -2);
                }
            }
        }
    }
}
