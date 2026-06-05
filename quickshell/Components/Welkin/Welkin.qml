import QtQuick

Item {
    id: root
    width: 1280
    height: 720
    scale: 0.75

    readonly property string welkinDir: Qt.resolvedUrl("../../Assets/welkin/")

    property real factorX: 0
    property real factorY: 0
    property real moonYOffset: 0
    property real girlYOffset: 0

    Behavior on factorX {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Behavior on factorY {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        NumberAnimation {
            target: root
            property: "moonYOffset"
            to: -15
            duration: 4000
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: root
            property: "moonYOffset"
            to: 0
            duration: 4000
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        NumberAnimation {
            target: root
            property: "girlYOffset"
            to: 8
            duration: 3000
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: root
            property: "girlYOffset"
            to: 0
            duration: 3000
            easing.type: Easing.InOutSine
        }
    }

    MouseArea {
        id: globalMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        property real targetX: 0
        property real targetY: 0

        onPositionChanged: mouse => {
            targetX = (mouse.x - width / 2) / (width / 2);
            targetY = (mouse.y - height / 2) / (height / 2);
        }

        onExited: {
            targetX = 0;
            targetY = 0;
        }

        Timer {
            interval: 16
            running: true
            repeat: true
            onTriggered: {
                root.factorX = globalMouse.targetX;
                root.factorY = globalMouse.targetY;
            }
        }
    }

    Image {
        id: bgImage
        source: root.welkinDir + "Img_MonthlyCardV2_Bg.png"
        anchors.centerIn: parent
        transform: Translate {
            x: root.factorX * 10
            y: root.factorY * 10
        }
    }

    Image {
        id: bgMask
        source: root.welkinDir + "Img_MonthlyCardV2_Bg_Mask.png"
        opacity: 0.6
        anchors.centerIn: parent
        transform: Translate {
            x: root.factorX * 15
            y: root.factorY * 15
        }
    }

    Image {
        id: moon
        source: root.welkinDir + "Img_MonthlyCard_Moon.png"
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -50
        anchors.verticalCenterOffset: -80
        transform: Translate {
            x: root.factorX * -25
            y: (root.factorY * -25) + root.moonYOffset
        }
    }

    Item {
        id: starsLayer
        anchors.fill: parent
        transform: Translate {
            x: root.factorX * -40
            y: root.factorY * -40
        }

        Image {
            source: root.welkinDir + "Img_MonthlyCardV2_Star1.png"
            x: 200
            y: 150
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.2
                    duration: 1500
                }
                NumberAnimation {
                    to: 1.0
                    duration: 1500
                }
            }
        }

        Image {
            source: root.welkinDir + "Img_MonthlyCardV2_Star2.png"
            x: 800
            y: 100
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.3
                    duration: 2200
                }
                NumberAnimation {
                    to: 1.0
                    duration: 1800
                }
            }
        }

        Image {
            source: root.welkinDir + "Img_MonthlyCardV2_Star3.png"
            x: 350
            y: 450
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.1
                    duration: 1800
                }
                NumberAnimation {
                    to: 0.9
                    duration: 2500
                }
            }
        }

        Image {
            source: root.welkinDir + "Img_MonthlyCardV2_Star4.png"
            x: 950
            y: 350
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.2
                    duration: 1200
                }
                NumberAnimation {
                    to: 1.0
                    duration: 1400
                }
            }
        }

        Image {
            source: root.welkinDir + "Img_MonthlyCardV2_Star5.png"
            x: 500
            y: 200
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.4
                    duration: 1900
                }
                NumberAnimation {
                    to: 1.0
                    duration: 1100
                }
            }
        }
    }

    Item {
        id: girlCharacter
        anchors.fill: parent
        transform: Translate {
            x: root.factorX * 25
            y: (root.factorY * 25) + root.girlYOffset
        }

        Image {
            id: girlBody
            source: root.welkinDir + "Img_MonthlyCardV2_Girl.png"
            anchors.centerIn: parent
        }

        Image {
            id: leftHand
            source: root.welkinDir + "Img_MonthlyCardV2_LeftHand2.png"
            x: girlBody.x + 120
            y: girlBody.y + 200

            SequentialAnimation on rotation {
                loops: Animation.Infinite
                NumberAnimation {
                    to: -3
                    duration: 2500
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: 3
                    duration: 2500
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Image {
            id: rightHand
            source: root.welkinDir + "Img_MonthlyCardV2_RightHand2.png"
            x: girlBody.x + 400
            y: girlBody.y + 180

            SequentialAnimation on rotation {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 4
                    duration: 2800
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: -2
                    duration: 2800
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Image {
            id: wand
            source: root.welkinDir + "Img_MonthlyCard_Wand.png"
            x: rightHand.x - 30
            y: rightHand.y - 120
            transformOrigin: Item.BottomLeft

            SequentialAnimation on rotation {
                loops: Animation.Infinite
                NumberAnimation {
                    to: 5
                    duration: 3500
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: -3
                    duration: 3500
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    Image {
        id: foregroundKuang
        source: root.welkinDir + "Img_MonthlyCardV2_Kuang02.png"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        transform: Translate {
            x: root.factorX * 35
            y: root.factorY * 10
        }
    }
}
