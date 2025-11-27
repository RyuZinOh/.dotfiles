import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import "Components"

Pane {
    id: root
    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width
    padding: 0
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true
    palette.window: "#000000"
    palette.highlight: "#ffffff"
    palette.highlightedText: "#000000"
    palette.buttonText: "#ffffff"
    font.family: config.Font || "Sans Serif"
    font.pointSize: config.FontSize !== "" ? config.FontSize : parseInt(height / 80) || 13
    focus: true

    Image {
        id: backgroundImage
        anchors.fill: parent
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        fillMode: Image.PreserveAspectCrop
        source: config.Background || config.background
        asynchronous: true
        cache: true
        mipmap: true
        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
        }
    }

    Rectangle {
        id: tintLayer
        anchors.fill: parent
        z: 1
        color: "#000000"
        opacity: 0.7
    }

    Quotes {
        id: quotesComponent
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 100
        }
        width: parent.width * 0.5
        z: 4
        quote: form.passwordLength > 0 ? "fuck yea!!" : config.Quote
        textColor: "#ffffff"
        fontSize: config.QuoteFontSize || 18
    }

    DateTime {
        id: dateTimeComponent
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: 40
            bottomMargin: 40
        }
        z: 4
        textColor: "#ffffff"
        dateFontSize: config.DateFontSize || 24
        timeFontSize: config.TimeFontSize || 48
    }

    SessionButton {
        id: sessionSelect
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        anchors.topMargin: 60
        z: 4
        model: sessionModel
        currentIndex: model.lastIndex
    }

    Item {
        id: centerContainer
        anchors.centerIn: parent
        width: 400
        height: 400
        z: 3

        Rectangle {
            anchors.centerIn: parent
            width: pfpContainer.width + 20
            height: pfpContainer.height + 20
            radius: width / 2
            color: "transparent"
            border.color: form.failed ? "#ff0000" : "white"
            border.width: 1
            opacity: 0.2
        }

        Repeater {
            model: form.passwordLength

            Text {
                id: kanjiChar
                property real baseAngle: (index * 360 / Math.max(form.passwordLength, 1))
                property real rotationOffset: 0
                property real currentDistance: 0
                property real targetDistance: 140 + (index % 2) * 20

                visible: true

                x: 200 + Math.cos((baseAngle + rotationOffset) * Math.PI / 180) * currentDistance - width / 2
                y: 200 + Math.sin((baseAngle + rotationOffset) * Math.PI / 180) * currentDistance - height / 2

                text: {               
                const kanjis = ['雷' //kaminari => thundah
                                , '龍' //ryu => doragaon
                                , '火' //ka => fire
                                , '水' //mizu => watah
                                , '風' //kaze => wind
                                , '月' //tsuki => moon
                                , '星' //hosshi => star
                                , '夢' //yume => dream
                                , '侍' //samurai
                                , '魂' //tamashi => soul
                                , '剣' //tsurugi => sword
                                , '神' //kami => god
                                , '虎' //tora => tiger
                                , '鳳' //ho => phoenix [ho-oh pokemon like]
                                , '雲' //kumo => cloud
                                , '霊' //rei => ghost
                            ];

                    return kanjis[index % kanjis.length];
                }

                font.pointSize: 24 + (index % 2) * 6
                color: "white"
                opacity: 0
                style: Text.Outline
                styleColor: "black"

                Component.onCompleted: {
                    currentDistance = targetDistance;
                    opacity = 0.4 - (index % 2) * 0.1;
                    rotationAnim.start();
                }

                NumberAnimation on rotationOffset {
                    id: rotationAnim
                    from: 0
                    to: 360
                    duration: 12000 + (index * 300)
                    loops: Animation.Infinite
                }
            }
        }

        Rectangle {
            id: pfpContainer
            width: 250
            height: 250
            anchors.centerIn: parent
            radius: width / 2
            color: form.failed ? "#ff0000" : "#00008B"
            antialiasing: true

            Image {
                id: userPfp
                width: parent.width - 8
                height: parent.height - 8
                anchors.centerIn: parent
                source: config.UserProfilePicture
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

            //fallback text
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

        //main ring
        Rectangle {
            anchors.fill: pfpContainer
            radius: width / 2
            color: "transparent"
            border.color: form.failed ? "#ff0000" : "#00008B"
            border.width: 3
        }
    }

    //hidden login form
    LoginForm {
        id: form
        anchors.centerIn: parent
        z: 2
        sessionIndex: sessionSelect.currentIndex
    }

    //subtle hint at bottom
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
            parent.forceActiveFocus();
            form.focusPassword();
        }
    }
}
