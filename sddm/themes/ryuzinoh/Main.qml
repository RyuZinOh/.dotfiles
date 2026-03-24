pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "Components"

Pane {
    id: root
    height: Screen.height
    width: Screen.width
    padding: 0
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true
    palette.window: "#000000"
    palette.highlight: "#ffffff"
    clip: true
    palette.highlightedText: "#000000"
    palette.buttonText: "#ffffff"
    font.family: "CaskaydiaCove NF"
    font.pointSize: 12
    focus: true

    readonly property string cfgBackground: Qt.resolvedUrl("Shiboing/tsubasa_maxxed.jpeg")
    readonly property string cfgUserProfilePicture: Qt.resolvedUrl("Shiboing/tsugaru.jpg")
    readonly property string cfgQuote: "Everything is Physics, When you don't know Magick..."
    readonly property int cfgQuoteFontSize: 25

    Wallpaper {
        source: root.cfgBackground
        pan: true
        z: 1
    }

    Quotes {
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 100
        }
        width: parent.width * 0.5
        z: 4
        quote: form.passwordLength > 0 ? "real shi..." : root.cfgQuote
        textColor: "#ffffff"
        fontSize: root.cfgQuoteFontSize
    }

    SessionButton {
        id: sessionSelect
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 40
        anchors.bottomMargin: 60
        z: 4
        model: sessionModel
        currentIndex: sessionModel.lastIndex
        parentFont: root.font
    }

    Item {
        id: centerContainer
        anchors.centerIn: parent
        width: 400
        height: 400
        z: 3

        Rectangle {
            anchors.centerIn: parent
            width: pfpContainer.width + 24
            height: pfpContainer.height + 24
            radius: width / 2
            color: "transparent"
            border.color: form.failed ? "#ff0000" : "#ffffff"
            border.width: 1
            opacity: 0.15

            Behavior on border.color {
                ColorAnimation {
                    duration: 300
                }
            }
        }

        Repeater {
            model: form.passwordLength

            Item {
                id: kanjiChar

                required property int index

                readonly property real orbitRadius: 118 + (kanjiChar.index % 2) * 12
                readonly property real baseAngle: kanjiChar.index * 360 / Math.max(form.passwordLength, 1)
                readonly property real fontSize: kanjiChar.index % 2 === 0 ? 18 : 16

                property real rotationOffset: 0

                x: 200 + Math.cos((baseAngle + rotationOffset) * Math.PI / 180) * orbitRadius - 12
                y: 200 + Math.sin((baseAngle + rotationOffset) * Math.PI / 180) * orbitRadius - 12
                width: 24
                height: 24
                opacity: 0

                Text {
                    anchors.centerIn: parent
                    text: {
                        const kanjis = ['雷', '龍', '火', '水', '風', '月', '星', '夢', '侍', '魂', '剣', '神', '虎', '鳳', '雲', '霊'];
                        return kanjis[kanjiChar.index % kanjis.length];
                    }
                    font.pointSize: kanjiChar.fontSize
                    color: "#ffffff"
                    style: Text.Outline
                    styleColor: "#000000"
                    opacity: kanjiChar.index % 2 === 0 ? 0.75 : 0.45
                }

                Component.onCompleted: {
                    opacity = 1;
                }

                NumberAnimation on rotationOffset {
                    from: 0
                    to: kanjiChar.index % 2 === 0 ? 360 : -360
                    duration: 18000 + kanjiChar.index * 500
                    loops: Animation.Infinite
                    running: true
                    easing.type: Easing.Linear
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Rectangle {
            id: pfpContainer
            width: 200
            height: 200
            anchors.centerIn: parent
            radius: width / 2
            color: form.failed ? "#ff0000" : "white"
            antialiasing: true

            Behavior on color {
                ColorAnimation {
                    duration: 300
                }
            }

            Image {
                id: userPfp
                width: parent.width - 8
                height: parent.height - 8
                anchors.centerIn: parent
                source: root.cfgUserProfilePicture
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: mask
                }

                Item {
                    id: mask
                    width: userPfp.width
                    height: userPfp.height
                    layer.enabled: true
                    visible: false
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "white"
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "?"
                font.pointSize: 80
                font.weight: Font.Light
                color: "white"
                visible: userPfp.status === Image.Error
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: form.focusPassword()
            }
        }

        Rectangle {
            anchors.fill: pfpContainer
            radius: width / 2
            color: "transparent"
            border.color: form.failed ? "#ff0000" : "white"
            border.width: 2
            antialiasing: true

            Behavior on border.color {
                ColorAnimation {
                    duration: 300
                }
            }
        }
    }

    LoginForm {
        id: form
        anchors.centerIn: parent
        z: 2
        sessionIndex: sessionSelect.currentIndex
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 60
        }
        text: "Press Enter to unlock"
        font.pointSize: 11
        font.weight: Font.Light
        color: "white"
        opacity: form.passwordLength > 0 ? 0.6 : 0
        z: 4
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.forceActiveFocus();
            form.focusPassword();
        }
    }
}
