pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import qs.Services.Theme
import qs.utils

Item {
    id: root
    width: 100
    height: 320
    visible: OsdConfig.isVisible

    readonly property int segmentCount: 15
    readonly property real normalizedValue: OsdConfig.currentValue / OsdConfig.maxLimit
    readonly property int filledSegments: Math.floor(normalizedValue * segmentCount)
    readonly property real partialFill: (normalizedValue * segmentCount) - filledSegments

    readonly property string displayKanji: {
        const s = filledSegments;
        if (OsdConfig.mode === "volume") {
            if (OsdConfig.isMuted) {
                return "無";
            }
            return ["零", "静", "寂", "微", "低", "弱", "柔", "穏", "和", "中", "響", "高", "強", "大", "轟", "最"][s] || "最";
        }
        return ["暗", "闇", "影", "微", "弱", "淡", "薄", "朧", "柔", "中", "煌", "強", "明", "輝", "燿", "曜"][s] || "曜";
    }

    readonly property int transitionDuration: 250
    readonly property int colorTransition: 200

    Column {
        anchors.centerIn: parent
        spacing: 18

        Item {
            width: 100
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter

            Item {
                id: ringContainer
                anchors.centerIn: parent
                width: 90
                height: 90

                readonly property real gapAngle: 60
                readonly property real gapCenterAngle: 140

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    radius: width / 2
                    color: Theme.surfaceContainerHigh
                    antialiasing: true
                }

                Shape {
                    id: ringShape
                    anchors.fill: parent

                    layer.enabled: true
                    layer.smooth: true
                    layer.samples: 4
                    antialiasing: true

                    ShapePath {
                        strokeWidth: 4
                        strokeColor: OsdConfig.isMuted ? Theme.outlineColor : Theme.primaryColor
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: ringShape.width / 2
                            centerY: ringShape.height / 2
                            radiusX: (ringShape.width - 4) / 2
                            radiusY: (ringShape.height - 4) / 2
                            startAngle: ringContainer.gapCenterAngle + ringContainer.gapAngle / 2
                            sweepAngle: 360 - ringContainer.gapAngle
                        }

                        Behavior on strokeColor {
                            ColorAnimation {
                                duration: root.colorTransition
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.displayKanji
                    font.family: "Noto Sans CJK JP"
                    font.pixelSize: 36
                    font.weight: Font.Bold
                    color: OsdConfig.isMuted ? Theme.onSurfaceVariant : Theme.primaryColor
                    antialiasing: true
                    renderType: Text.NativeRendering

                    Behavior on color {
                        ColorAnimation {
                            duration: root.colorTransition
                        }
                    }
                }

                Text {
                    id: percentageText
                    text: OsdConfig.currentValue + "%"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    font.family: "CaskaydiaCove NF"
                    color: OsdConfig.isMuted ? Theme.onSurfaceVariant : Theme.primaryColor
                    renderType: Text.NativeRendering

                    property real radius: (ringContainer.width - 4) / 2

                    x: ringContainer.width / 2 + percentageText.radius * Math.cos(ringContainer.gapCenterAngle * Math.PI / 180) - percentageText.width / 2
                    y: ringContainer.height / 2 + percentageText.radius * Math.sin(ringContainer.gapCenterAngle * Math.PI / 180) - percentageText.height / 2

                    Behavior on color {
                        ColorAnimation {
                            duration: root.colorTransition
                        }
                    }
                }
            }
        }

        Item {
            width: 70
            height: 210
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2.5

                Repeater {
                    model: root.segmentCount

                    delegate: SegmentShape {
                        required property int index
                        segmentIndex: root.segmentCount - 1 - index
                        totalSegments: root.segmentCount
                        filledCount: root.filledSegments
                        partialAmount: root.partialFill
                        isMuted: OsdConfig.isMuted
                    }
                }
            }
        }
    }

    component SegmentShape: Item {
        id: segment
        property int segmentIndex: 0
        property int totalSegments: 15
        property int filledCount: 0
        property real partialAmount: 0
        property bool isMuted: false

        readonly property bool isActive: segmentIndex === filledCount - 1 && filledCount > 0
        readonly property real fillAmount: {
            if (segmentIndex < filledCount) {
                return 1.0;
            }
            if (segmentIndex === filledCount) {
                return partialAmount;
            }
            return 0.0;
        }

        readonly property real curveOffset: {
            const normalizedPos = (totalSegments - 1 - segmentIndex) / (totalSegments - 1);
            const centered = (normalizedPos - 0.5) * 2;
            return Math.pow(centered, 2) * 22;
        }

        readonly property real baseHeight: (210 - (2.5 * (totalSegments - 1))) / totalSegments
        readonly property real actualHeight: isActive ? baseHeight * 1.35 : baseHeight

        width: 65
        height: actualHeight
        x: curveOffset

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true
            layer.samples: 4

            ShapePath {
                strokeColor: "transparent"
                strokeWidth: 0
                fillColor: Theme.surfaceContainer

                startX: segment.width * 0.12
                startY: 0
                PathLine {
                    x: segment.width * 0.88
                    y: 0
                }
                PathLine {
                    x: segment.width
                    y: segment.actualHeight
                }
                PathLine {
                    x: 0
                    y: segment.actualHeight
                }
                PathLine {
                    x: segment.width * 0.12
                    y: 0
                }
            }
        }

        Item {
            id: fillContainer
            anchors.fill: parent
            clip: true

            readonly property real indent: segment.width * 0.12
            readonly property real fillHeight: segment.actualHeight * segment.fillAmount
            readonly property real topY: segment.actualHeight - fillHeight
            readonly property real topIndent: fillHeight >= segment.actualHeight ? indent : indent + (segment.width * 0.38 - indent) * (topY / segment.actualHeight)

            Shape {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: fillContainer.fillHeight
                layer.enabled: true
                layer.smooth: true
                layer.samples: 4

                ShapePath {
                    strokeColor: "transparent"
                    fillColor: segment.isMuted ? Theme.outlineColor : Theme.primaryColor

                    startX: fillContainer.fillHeight >= segment.actualHeight ? fillContainer.indent : fillContainer.topIndent
                    startY: fillContainer.fillHeight >= segment.actualHeight ? 0 : fillContainer.topY

                    PathLine {
                        x: fillContainer.fillHeight >= segment.actualHeight ? segment.width - fillContainer.indent : segment.width - fillContainer.topIndent
                        y: fillContainer.fillHeight >= segment.actualHeight ? 0 : fillContainer.topY
                    }
                    PathLine {
                        x: segment.width
                        y: segment.actualHeight
                    }
                    PathLine {
                        x: 0
                        y: segment.actualHeight
                    }
                    PathLine {
                        x: fillContainer.fillHeight >= segment.actualHeight ? fillContainer.indent : fillContainer.topIndent
                        y: fillContainer.fillHeight >= segment.actualHeight ? 0 : fillContainer.topY
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
