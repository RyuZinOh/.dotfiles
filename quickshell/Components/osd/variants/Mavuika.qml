pragma ComponentBehavior: Bound

import QtQuick
import qs.Services.Paths
import qs.Services.Kraken

Item {
    id: root
    width: 140
    height: width * 1.8

    property real normalizedValue: 0
    property int currentStep: Math.round(normalizedValue * 10)

    property url spriteCache: Qt.resolvedUrl("../../../Assets/nightsoul/Mavuika")
    property string shaderPath: PathService.home + "/.cache/safalQuick/shaders/flame"

    property var positions: ({})

    Kraken {
        id: posData
        filePath: root.spriteCache.toString().replace("file://", "") + "/pos.json"
        onDataLoaded: root.positions = posData.get("positions", posData.data)
    }

    Item {
        id: canvas
        width: 512
        height: 660
        transformOrigin: Item.TopLeft
        scale: root.width / 512
        x: 0
        y: -40

        Item {
            anchors.fill: barBg
            z: 1

            Item {
                anchors.fill: parent
                layer.enabled: true
                layer.effect: ShaderEffect {
                    property real time: 0
                    NumberAnimation on time {
                        from: 0
                        to: 100
                        duration: 100000
                        loops: Animation.Infinite
                        running: true
                    }
                    vertexShader: root.shaderPath + "/flame.vert.qsb"
                    fragmentShader: root.shaderPath + "/flame.frag.qsb"
                }

                Image {
                    anchors.fill: parent
                    source: root.spriteCache + "/UI_NyxStateBar_Mavuika_EffColorShadow.png"
                }
                Image {
                    anchors.fill: parent
                    source: root.spriteCache + "/UI_NyxStateBar_Mavuika_EffColor.png"
                }
                Image {
                    anchors.fill: parent
                    source: root.spriteCache + "/UI_NyxStateBar_Mavuika_EffColor02.png"
                }
            }
        }

        Image {
            id: barBg
            x: 0
            y: 0
            width: 512
            height: 660
            source: root.spriteCache + "/UI_NyxStateBar_Mavuika_BarBg.png"
            z: 2
        }

        Repeater {
            model: 10

            Item {
                id: chip
                required property int index

                property string fname: "UI_NyxStateBar_Mavuika_Scale0" + chip.index + ".png"
                property var p: root.positions[chip.fname] ?? {
                    x: 0,
                    y: 0,
                    r: 0
                }

                x: chip.p.x
                y: chip.p.y
                rotation: chip.p.r
                z: 4
                visible: chip.index >= (10 - root.currentStep)
                width: img.implicitWidth
                height: img.implicitHeight

                Image {
                    id: img
                    source: root.spriteCache + "/" + chip.fname
                    fillMode: Image.Pad
                }
            }
        }
    }
}
