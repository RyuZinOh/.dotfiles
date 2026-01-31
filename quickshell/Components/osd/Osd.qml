pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import qs.Services.Theme
import qs.utils

Item {
    id: root
    width: 150
    height: 600
    visible: OsdConfig.isVisible

    readonly property string spriteCache: "/home/safal726/.cache/safalQuick/nightsoul/Chasca"

    readonly property int segmentCount: 15
    property real normalizedValue: 0
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

    readonly property int colorTransition: 200

    Behavior on normalizedValue {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Connections {
        target: OsdConfig
        function onCurrentValueChanged() {
            root.normalizedValue = Math.max(0, Math.min(1, OsdConfig.currentValue / 100));
        }
    }

    Component.onCompleted: {
        root.normalizedValue = Math.max(0, Math.min(1, OsdConfig.currentValue / 100));
    }

    Item {
        id: ringContainer
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 90
        height: 90
        z: 2

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

    Item {
        id: chascaBar
        anchors.top: ringContainer.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: 120
        height: width * 1.42
        z: 1

        Image {
            anchors.fill: parent
            source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarBg.png"
            fillMode: Image.PreserveAspectFit
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height * root.normalizedValue
            clip: true

            Image {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: chascaBar.width
                height: chascaBar.height
                source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarFill.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        Image {
            anchors.fill: parent
            source: root.spriteCache + "/UI_NyxStateBar_Chasca_EffColor_02.png"
            fillMode: Image.PreserveAspectFit
            opacity: 0.6
        }

        Image {
            anchors.fill: parent
            source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarMask.png"
            fillMode: Image.PreserveAspectFit
        }

        Image {
            anchors.fill: parent
            source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarBg02.png"
            fillMode: Image.PreserveAspectFit
        }

        Image {
            anchors.fill: parent
            source: root.spriteCache + "/UI_NyxStateBar_Chasca_Mask_02.png"
            fillMode: Image.PreserveAspectFit
        }
    }
}
