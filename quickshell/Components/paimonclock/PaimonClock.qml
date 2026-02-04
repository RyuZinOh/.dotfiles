import QtQuick
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: paimon
    width: 1200
    height: 800

    property real offsetX: 0
    property real offsetY: 0

    property string spritePath: "/home/safal726/.cache/safalQuick/Time/"
    property string jsonFilePath: spritePath + "spritesmall.json"
    property var spriteData: ({})
    property real horoscopeX: 491.7512018672653
    property real horoscopeY: 266.001274283757
    property real horoscopeSize: 159.4725552479834

    property int currentHour: clock.hours
    property int currentMinute: clock.minutes
    property int currentSecond: clock.seconds

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Process {
        id: loadProcess
        running: true
        command: ["cat", paimon.jsonFilePath]

        stdout: StdioCollector {
            id: loadStdout
        }

        onExited: function (exitCode, exitStatus) {
            if (exitCode === 0 && loadStdout.data) {
                try {
                    var loadedData = JSON.parse(loadStdout.data);

                    if (loadedData.sprites) {
                        paimon.spriteData = loadedData.sprites;
                    } else {
                        paimon.spriteData = loadedData;
                    }

                    if (loadedData.horoscope) {
                        paimon.horoscopeX = loadedData.horoscope.x;
                        paimon.horoscopeY = loadedData.horoscope.y;
                        paimon.horoscopeSize = loadedData.horoscope.size;
                    }
                    console.log("Successfully loaded spritesmall.json");
                } catch (e) {
                    console.log("Error parsing JSON:", e);
                }
            } else {
                console.log("Could not load spritesmall.json");
            }
        }
    }

    Item {
        id: clippedSpritesContainer
        width: parent.width
        height: parent.height

        Item {
            id: spritesToClip
            width: parent.width
            height: parent.height
            visible: false

            Image {
                id: horoscopeBg
                x: paimon.horoscopeX + paimon.offsetX
                y: paimon.horoscopeY + paimon.offsetY
                source: paimon.spritePath + "UI_Img_HoroscopeBg.png"
                width: implicitWidth * (paimon.horoscopeSize * 2 / implicitWidth)
                height: implicitHeight * (paimon.horoscopeSize * 2 / implicitHeight)
                smooth: true
            }

            Image {
                id: horoscope06
                x: (paimon.spriteData["UI_Img_Horoscope06.png"] ? paimon.spriteData["UI_Img_Horoscope06.png"].x : 555.290076607798) + paimon.offsetX
                y: (paimon.spriteData["UI_Img_Horoscope06.png"] ? paimon.spriteData["UI_Img_Horoscope06.png"].y : 327.2220325852926) + paimon.offsetY
                source: paimon.spritePath + "UI_Img_Horoscope06.png"
                width: implicitWidth * (paimon.spriteData["UI_Img_Horoscope06.png"] ? paimon.spriteData["UI_Img_Horoscope06.png"].scale : 0.3)
                height: implicitHeight * (paimon.spriteData["UI_Img_Horoscope06.png"] ? paimon.spriteData["UI_Img_Horoscope06.png"].scale : 0.3)
                smooth: true

                transform: Rotation {
                    origin.x: horoscope06.width / 2
                    origin.y: horoscope06.height / 2
                    angle: -(paimon.currentSecond * 12) % 360

                    Behavior on angle {
                        RotationAnimation {
                            duration: 1000
                            direction: RotationAnimation.Counterclockwise
                        }
                    }
                }
            }

            Image {
                id: horoscope03
                x: (paimon.spriteData["UI_Img_Horoscope03.png"] ? paimon.spriteData["UI_Img_Horoscope03.png"].x : 519.274286562527) + paimon.offsetX
                y: (paimon.spriteData["UI_Img_Horoscope03.png"] ? paimon.spriteData["UI_Img_Horoscope03.png"].y : 268.5445560932224) + paimon.offsetY
                source: paimon.spritePath + "UI_Img_Horoscope03.png"
                width: implicitWidth * (paimon.spriteData["UI_Img_Horoscope03.png"] ? paimon.spriteData["UI_Img_Horoscope03.png"].scale : 0.3)
                height: implicitHeight * (paimon.spriteData["UI_Img_Horoscope03.png"] ? paimon.spriteData["UI_Img_Horoscope03.png"].scale : 0.3)
                smooth: true

                transform: Rotation {
                    origin.x: horoscope03.width / 2
                    origin.y: horoscope03.height / 2
                    angle: (paimon.currentSecond * 6) % 360

                    Behavior on angle {
                        RotationAnimation {
                            duration: 1000
                            direction: RotationAnimation.Clockwise
                        }
                    }
                }
            }

            Image {
                id: horoscope04
                x: (paimon.spriteData["UI_Img_Horoscope04.png"] ? paimon.spriteData["UI_Img_Horoscope04.png"].x : 495.13828693922414) + paimon.offsetX
                y: (paimon.spriteData["UI_Img_Horoscope04.png"] ? paimon.spriteData["UI_Img_Horoscope04.png"].y : 296.86442466304675) + paimon.offsetY
                source: paimon.spritePath + "UI_Img_Horoscope04.png"
                width: implicitWidth * (paimon.spriteData["UI_Img_Horoscope04.png"] ? paimon.spriteData["UI_Img_Horoscope04.png"].scale : 0.3)
                height: implicitHeight * (paimon.spriteData["UI_Img_Horoscope04.png"] ? paimon.spriteData["UI_Img_Horoscope04.png"].scale : 0.3)
                smooth: true

                transform: Rotation {
                    origin.x: horoscope04.width / 2
                    origin.y: horoscope04.height / 2
                    angle: -(paimon.currentSecond * 6) % 360

                    Behavior on angle {
                        RotationAnimation {
                            duration: 1000
                            direction: RotationAnimation.Counterclockwise
                        }
                    }
                }
            }

            Image {
                id: horoscope05
                x: (paimon.spriteData["UI_Img_Horoscope05.png"] ? paimon.spriteData["UI_Img_Horoscope05.png"].x : 587.5585568820654) + paimon.offsetX
                y: (paimon.spriteData["UI_Img_Horoscope05.png"] ? paimon.spriteData["UI_Img_Horoscope05.png"].y : 365.3415312577068) + paimon.offsetY
                source: paimon.spritePath + "UI_Img_Horoscope05.png"
                width: implicitWidth * (paimon.spriteData["UI_Img_Horoscope05.png"] ? paimon.spriteData["UI_Img_Horoscope05.png"].scale : 0.3)
                height: implicitHeight * (paimon.spriteData["UI_Img_Horoscope05.png"] ? paimon.spriteData["UI_Img_Horoscope05.png"].scale : 0.3)
                smooth: true

                transform: Rotation {
                    origin.x: horoscope05.width / 2
                    origin.y: horoscope05.height / 2
                    angle: (paimon.currentSecond * 12) % 360

                    Behavior on angle {
                        RotationAnimation {
                            duration: 1000
                            direction: RotationAnimation.Clockwise
                        }
                    }
                }
            }

            Image {
                id: clockCircle
                x: (paimon.spriteData["UI_Clock_Circle.png"] ? paimon.spriteData["UI_Clock_Circle.png"].x : 561.6509319793329) + paimon.offsetX
                y: (paimon.spriteData["UI_Clock_Circle.png"] ? paimon.spriteData["UI_Clock_Circle.png"].y : 334.3911367580977) + paimon.offsetY
                source: paimon.spritePath + "UI_Clock_Circle.png"
                width: implicitWidth * (paimon.spriteData["UI_Clock_Circle.png"] ? paimon.spriteData["UI_Clock_Circle.png"].scale : 0.3)
                height: implicitHeight * (paimon.spriteData["UI_Clock_Circle.png"] ? paimon.spriteData["UI_Clock_Circle.png"].scale : 0.3)
                smooth: true
            }

            Image {
                id: minuteHand
                x: (paimon.spriteData["UI_Clock_MinuteHand.png"] ? paimon.spriteData["UI_Clock_MinuteHand.png"].x : 562.1112975037765) + paimon.offsetX
                y: (paimon.spriteData["UI_Clock_MinuteHand.png"] ? paimon.spriteData["UI_Clock_MinuteHand.png"].y : 349.5442457209266) + paimon.offsetY
                source: paimon.spritePath + "UI_Clock_MinuteHand.png"
                width: implicitWidth * (paimon.spriteData["UI_Clock_MinuteHand.png"] ? paimon.spriteData["UI_Clock_MinuteHand.png"].scale : 0.3)
                height: implicitHeight * (paimon.spriteData["UI_Clock_MinuteHand.png"] ? paimon.spriteData["UI_Clock_MinuteHand.png"].scale : 0.3)
                smooth: true

                transform: Rotation {
                    origin.x: (clockCircle.x + clockCircle.width / 2) - minuteHand.x
                    origin.y: (clockCircle.y + clockCircle.height / 2) - minuteHand.y
                    angle: (paimon.currentMinute * 6) + (paimon.currentSecond * 0.1) - 180

                    Behavior on angle {
                        RotationAnimation {
                            duration: 500
                            direction: RotationAnimation.Clockwise
                        }
                    }
                }
            }

            Image {
                id: hourHand
                x: (paimon.spriteData["UI_Clock_HourHand.png"] ? paimon.spriteData["UI_Clock_HourHand.png"].x : 557.4161882113638) + paimon.offsetX
                y: (paimon.spriteData["UI_Clock_HourHand.png"] ? paimon.spriteData["UI_Clock_HourHand.png"].y : 284.4752534421497) + paimon.offsetY
                source: paimon.spritePath + "UI_Clock_HourHand.png"
                width: implicitWidth * (paimon.spriteData["UI_Clock_HourHand.png"] ? paimon.spriteData["UI_Clock_HourHand.png"].scale : 0.3)
                height: implicitHeight * (paimon.spriteData["UI_Clock_HourHand.png"] ? paimon.spriteData["UI_Clock_HourHand.png"].scale : 0.3)
                smooth: true

                transform: Rotation {
                    origin.x: (clockCircle.x + clockCircle.width / 2) - hourHand.x
                    origin.y: (clockCircle.y + clockCircle.height / 2) - hourHand.y
                    angle: ((paimon.currentHour % 12) * 30) + (paimon.currentMinute * 0.5) - 42

                    Behavior on angle {
                        enabled: false
                    }
                }
            }
        }

        Item {
            id: circleMaskSource
            width: parent.width
            height: parent.height
            visible: false

            Rectangle {
                x: paimon.horoscopeX + paimon.offsetX
                y: paimon.horoscopeY + paimon.offsetY
                width: paimon.horoscopeSize
                height: paimon.horoscopeSize
                radius: width / 2
                color: "white"
            }
        }

        OpacityMask {
            anchors.fill: parent
            source: spritesToClip
            maskSource: circleMaskSource
        }
    }

    Image {
        id: clockDial
        x: (paimon.spriteData["UI_Clock_Dial_NoTag.png"] ? paimon.spriteData["UI_Clock_Dial_NoTag.png"].x : 367.30117737851197) + paimon.offsetX
        y: (paimon.spriteData["UI_Clock_Dial_NoTag.png"] ? paimon.spriteData["UI_Clock_Dial_NoTag.png"].y : 140.14724814598839) + paimon.offsetY
        source: paimon.spritePath + "UI_Clock_Dial_NoTag.png"
        width: implicitWidth * (paimon.spriteData["UI_Clock_Dial_NoTag.png"] ? paimon.spriteData["UI_Clock_Dial_NoTag.png"].scale : 0.4)
        height: implicitHeight * (paimon.spriteData["UI_Clock_Dial_NoTag.png"] ? paimon.spriteData["UI_Clock_Dial_NoTag.png"].scale : 0.4)
        smooth: true
        z: 100
    }

    Image {
        id: iconMorning
        x: (paimon.spriteData["UI_ClockIcon_Morning.png"] ? paimon.spriteData["UI_ClockIcon_Morning.png"].x : 418.8849628332231) + paimon.offsetX
        y: (paimon.spriteData["UI_ClockIcon_Morning.png"] ? paimon.spriteData["UI_ClockIcon_Morning.png"].y : 322.6623744021117) + paimon.offsetY
        source: paimon.spritePath + "UI_ClockIcon_Morning.png"
        width: implicitWidth * (paimon.spriteData["UI_ClockIcon_Morning.png"] ? paimon.spriteData["UI_ClockIcon_Morning.png"].scale : 0.4)
        height: implicitHeight * (paimon.spriteData["UI_ClockIcon_Morning.png"] ? paimon.spriteData["UI_ClockIcon_Morning.png"].scale : 0.4)
        smooth: true
        visible: paimon.currentHour >= 0 && paimon.currentHour < 6
        z: 200
    }

    Image {
        id: iconNoon
        x: (paimon.spriteData["UI_ClockIcon_Noon.png"] ? paimon.spriteData["UI_ClockIcon_Noon.png"].x : 546.9263166977312) + paimon.offsetX
        y: (paimon.spriteData["UI_ClockIcon_Noon.png"] ? paimon.spriteData["UI_ClockIcon_Noon.png"].y : 192.52359185561664) + paimon.offsetY
        source: paimon.spritePath + "UI_ClockIcon_Noon.png"
        width: implicitWidth * (paimon.spriteData["UI_ClockIcon_Noon.png"] ? paimon.spriteData["UI_ClockIcon_Noon.png"].scale : 0.4)
        height: implicitHeight * (paimon.spriteData["UI_ClockIcon_Noon.png"] ? paimon.spriteData["UI_ClockIcon_Noon.png"].scale : 0.4)
        smooth: true
        visible: paimon.currentHour >= 6 && paimon.currentHour < 12
        z: 200
    }

    Image {
        id: iconDusk
        x: (paimon.spriteData["UI_ClockIcon_Dusk.png"] ? paimon.spriteData["UI_ClockIcon_Dusk.png"].x : 679.1824669305718) + paimon.offsetX
        y: (paimon.spriteData["UI_ClockIcon_Dusk.png"] ? paimon.spriteData["UI_ClockIcon_Dusk.png"].y : 327.2844619722338) + paimon.offsetY
        source: paimon.spritePath + "UI_ClockIcon_Dusk.png"
        width: implicitWidth * (paimon.spriteData["UI_ClockIcon_Dusk.png"] ? paimon.spriteData["UI_ClockIcon_Dusk.png"].scale : 0.4)
        height: implicitHeight * (paimon.spriteData["UI_ClockIcon_Dusk.png"] ? paimon.spriteData["UI_ClockIcon_Dusk.png"].scale : 0.4)
        smooth: true
        visible: paimon.currentHour >= 12 && paimon.currentHour < 18
        z: 200
    }

    Image {
        id: iconNight
        x: (paimon.spriteData["UI_ClockIcon_Night.png"] ? paimon.spriteData["UI_ClockIcon_Night.png"].x : 547.8047342303025) + paimon.offsetX
        y: (paimon.spriteData["UI_ClockIcon_Night.png"] ? paimon.spriteData["UI_ClockIcon_Night.png"].y : 449.4770614272038) + paimon.offsetY
        source: paimon.spritePath + "UI_ClockIcon_Night.png"
        width: implicitWidth * (paimon.spriteData["UI_ClockIcon_Night.png"] ? paimon.spriteData["UI_ClockIcon_Night.png"].scale : 0.4)
        height: implicitHeight * (paimon.spriteData["UI_ClockIcon_Night.png"] ? paimon.spriteData["UI_ClockIcon_Night.png"].scale : 0.4)
        smooth: true
        visible: paimon.currentHour >= 18 && paimon.currentHour <= 23
        z: 200
    }
}
