pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    width: 150
    height: 450
    y: -120

    property real normalizedValue: 0
    property string spriteCache: ""

    readonly property int zBarBg: 1
    readonly property int zBarFillOutline: 2
    readonly property int zBarFill: 3
    readonly property int zBarFillLight: -10
    readonly property int zBarShadow: -1
    readonly property int zBarEffMask: 6
    readonly property int zDots: 7

    ShaderEffect {
        x: 40
        y: 150
        width: 48
        height: 140
        z: root.zBarFillLight

        property variant source: Image {
            source: root.spriteCache + "/UI_NyxStateBar_SKK_BarFill_Light.png"
            fillMode: Image.PreserveAspectFit
        }

        property real time: 0

        NumberAnimation on time {
            from: 0
            to: 100
            duration: 100000
            loops: Animation.Infinite
            running: true
        }

        vertexShader: root.spriteCache + "/barfill.vert.qsb"
        fragmentShader: root.spriteCache + "/barfill.frag.qsb"
    }

    Image {
        id: barBg
        x: 26
        y: 150
        width: 80
        source: root.spriteCache + "/UI_NyxStateBar_SKK_BarBg.png"
        fillMode: Image.PreserveAspectFit
        z: root.zBarBg
    }

    Item {
        id: barClipContainer
        x: 23
        anchors.bottom: barBg.bottom
        width: 80
        height: 140
        clip: true
        z: root.zBarFillOutline

        Item {
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.height * root.normalizedValue

            Image {
                anchors.bottom: parent.bottom
                width: barClipContainer.width
                source: root.spriteCache + "/UI_NyxStateBar_SKK_BarFill.png"
                fillMode: Image.PreserveAspectFit
            }
            Image {
                anchors.bottom: parent.bottom
                x: 16
                width: 48
                source: root.spriteCache + "/UI_NyxStateBar_SKK_BarFill_Outline.png"
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    Item {
        x: -11
        anchors.bottom: barBg.bottom
        width: 150
        clip: true
        height: 150 * root.normalizedValue
        z: root.zBarEffMask

        Image {
            anchors.bottom: parent.bottom
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_BarEff_Mask.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    Item {
        id: dot0
        x: 2
        y: 288
        width: 35
        height: 35
        z: root.zDots
        readonly property real threshold: 0.25
        readonly property bool active: root.normalizedValue >= threshold

        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg02.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg_Light.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot0.active ? 1 : 0.3
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotFill.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot0.active ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Image {
            anchors.centerIn: parent
            width: parent.width * 1.5
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotFill_Light.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot0.active ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
    }

    Item {
        id: dot1
        x: -15
        y: 190
        width: 35
        height: 35
        z: root.zDots + 1
        readonly property real threshold: 0.50
        readonly property bool active: root.normalizedValue >= threshold

        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg02.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg_Light.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot1.active ? 1 : 0.3
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotFill.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot1.active ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Image {
            anchors.centerIn: parent
            width: parent.width * 1.5
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotFill_Light.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot1.active ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
    }

    Item {
        id: dot2
        x: 34
        y: 97
        width: 35
        height: 35
        z: root.zDots + 2
        readonly property real threshold: 0.75
        readonly property bool active: root.normalizedValue >= threshold

        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg02.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg_Light.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot2.active ? 1 : 0.3
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotFill.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot2.active ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Image {
            anchors.centerIn: parent
            width: parent.width * 1.5
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotFill_Light02.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot2.active ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
    }
}
