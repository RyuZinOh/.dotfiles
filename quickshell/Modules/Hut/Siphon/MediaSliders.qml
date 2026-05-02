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
        border.color: Theme.outlineVariant
        border.width: 1
    }

    Row {
        id: slidersRow
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
            shapeIdx: 8
            iconLow: "\uf027"
            iconMid: "\uf027"
            iconHigh: "\uf028"
            iconMuted: "\uf026"
            onScrubUp: OsdConfig.adjustVolume("2%+")
            onScrubDown: OsdConfig.adjustVolume("2%-")
        }

        MediaSlider {
            id: brightSlider
            width: 52
            height: parent.height
            value: brightnessVal
            shapeIdx: 14
            iconLow: "\udb80\udcde"
            iconMid: "\udb80\udcdd"
            iconHigh: "\udb80\udce0"

            property int brightnessVal: 50

            onScrubUp: {
                brightnessVal = Math.min(100, brightnessVal + 2);
                OsdConfig.adjustBrightness("2%+");
            }
            onScrubDown: {
                brightnessVal = Math.max(0, brightnessVal - 2);
                OsdConfig.adjustBrightness("2%-");
            }

            Connections {
                target: OsdConfig
                function onCurrentValueChanged() {
                    if (OsdConfig.mode === "brightness")
                        brightSlider.brightnessVal = OsdConfig.currentValue;
                }
            }

            Process {
                id: brightnessQuery
                command: ["sh", "-c", "brightnessctl -m | awk -F, '{print substr($4, 1, length($4)-1)}'"]
                stdout: StdioCollector {
                    onStreamFinished: brightSlider.brightnessVal = Math.round(parseFloat(text.trim()))
                }
            }
            Component.onCompleted: brightnessQuery.running = true
        }
    }

    Rectangle {
        id: muteBg
        width: 48
        height: 48
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        radius: 14
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1

        ShapeCanvas {
            anchors.centerIn: parent
            width: 36
            height: 36
            roundedPolygon: GetMShapes.get(2)
            color: OsdConfig.sinkMuted ? Theme.tertiaryColor : Theme.tertiaryContainer
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
            color: OsdConfig.sinkMuted ? Theme.onTertiary : Theme.onTertiaryContainer
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
        required property int shapeIdx
        required property string iconLow
        required property string iconMid
        required property string iconHigh
        property string iconMuted: ""
        property bool muted: false

        signal scrubUp
        signal scrubDown

        readonly property real thumbH: 38
        readonly property real travelH: ms.height - ms.thumbH
        readonly property real fillFrac: ms.muted ? 0 : ms.value / 100

        readonly property string currentIcon: {
            if (ms.muted && ms.iconMuted !== "")
                return ms.iconMuted;
            if (ms.value >= 66)
                return ms.iconHigh;
            if (ms.value >= 33)
                return ms.iconMid;
            return ms.iconLow;
        }

        Item {
            anchors.centerIn: parent
            width: 36
            height: ms.height

            ClippingRectangle {
                anchors.fill: parent
                radius: 18
                color: Theme.surfaceContainerHighest

                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                    height: parent.height * ms.fillFrac
                    color: Theme.tertiaryFixed
                    Behavior on height {
                        NumberAnimation {
                            duration: 80
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: ms.thumbH
                height: ms.thumbH
                y: ms.travelH * (1 - ms.fillFrac)
                Behavior on y {
                    NumberAnimation {
                        duration: 80
                        easing.type: Easing.OutCubic
                    }
                }

                ShapeCanvas {
                    anchors.fill: parent
                    roundedPolygon: GetMShapes.get(ms.shapeIdx)
                    color: Theme.tertiaryColor
                }

                Text {
                    anchors.centerIn: parent
                    text: ms.currentIcon
                    font {
                        family: "CaskaydiaCove NF"
                        pixelSize: 15
                    }
                    color: Theme.onTertiary
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
                    const dy = startY - e.y;
                    const newVal = Math.max(0, Math.min(100, Math.round(startVal + dy / ms.travelH * 100)));
                    if (newVal > ms.value)
                        ms.scrubUp();
                    else if (newVal < ms.value)
                        ms.scrubDown();
                    startY = e.y;
                    startVal = ms.value;
                }
                onWheel: w => {
                    const d = w.angleDelta.y !== 0 ? w.angleDelta.y : -w.angleDelta.x;
                    if (d > 0)
                        ms.scrubUp();
                    else
                        ms.scrubDown();
                }
            }
        }
    }
}
