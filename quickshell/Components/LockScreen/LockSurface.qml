import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Qt5Compat.GraphicalEffects
import Quickshell

Rectangle {
    id: root
    required property LockContext context

    color: "black"

    Image {
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/.cache/safalQuick/bg.jpg"
        fillMode: Image.PreserveAspectCrop

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.5
        }
    }

    Label {
        id: quoteLabel
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 100
        }

        width: parent.width * 0.5
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap

        font.pointSize: 18
        font.italic: true
        color: "white"
        opacity: 0.9

        text: passwordBox.text.length > 0 ? "Fuck Do I care..." : "Do they know what u doing?"

        Behavior on text {
            SequentialAnimation {
                NumberAnimation {
                    target: quoteLabel
                    property: "opacity"
                    to: 0
                    duration: 150
                }
                PropertyAction {
                    target: quoteLabel
                    property: "text"
                }
                NumberAnimation {
                    target: quoteLabel
                    property: "opacity"
                    to: 0.9
                    duration: 150
                }
            }
        }
    }

    Item {
        anchors.centerIn: parent
        width: 400
        height: childrenRect.height

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30

            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 200
                height: 200

                // Outer ring 
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 20
                    height: parent.height + 20
                    radius: width / 2
                    color: "transparent"
                    border.color: root.context.showFailure ? "#ff0000" : "white"
                    border.width: 1
                    opacity: 0.2
                }
                // appear when typing
                Repeater {
                    model: passwordBox.text.length

                    Text {
                        property real angle: (index * 360 / Math.max(passwordBox.text.length, 1))
                        property real distance: 120 + (index % 2) * 20

                        visible: true

                        x: 100 + Math.cos(angle * Math.PI / 180) * distance - width / 2
                        y: 100 + Math.sin(angle * Math.PI / 180) * distance - height / 2

                        text: {
                            //add anything you like i recommend using sanskrit or some ancient language but I like this
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

                        font.pointSize: 18 + (index % 2) * 4
                        color: "white"
                        // opacity: 0.3 - (index % 2) * 0.05
                        // style: Text.Outline
                        // styleColor: "black"

                        transform: Rotation {
                            origin.x: 0
                            origin.y: 0
                            angle: index * 20

                            RotationAnimation on angle {
                                running: true
                                loops: Animation.Infinite
                                from: index * 20
                                to: index * 20 + 360
                                duration: 12000 + (index * 300)
                            }
                        }
                    }
                }

                // pfp container
                Rectangle {
                    id: pfpContainer
                    anchors.fill: parent
                    radius: width / 2
                    color: root.context.showFailure ? "#ff0000" : "#00008B"

                    Image {
                        id: pfpImage
                        anchors.fill: parent
                        anchors.margins: 4
                        source: "file://" + Quickshell.env("HOME") + "/.cache/safalQuick/pfp.jpeg"
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                        cache: false

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: pfpContainer.width - 8
                                height: pfpContainer.height - 8
                                radius: width / 2
                            }
                        }

                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.error("failed to Load Pfp", source);
                            } else if (status === Image.Ready) {
                                console.log("pfp success");
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "?"
                        font.pointSize: 64
                        font.weight: Font.Light
                        color: "white"
                        visible: pfpImage.status === Image.Error
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            passwordBox.forceActiveFocus();
                        }
                    }
                }

                // Main border ring
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: root.context.showFailure ? "#ff0000" : "#00008B"
                    border.width: 3
                }
            }

            // Password input, always focued here
            TextInput {
                id: passwordBox
                visible: false
                enabled: !root.context.unlockInProgress
                focus: true

                Component.onCompleted: {
                    forceActiveFocus();
                }

                onTextChanged: {
                    root.context.currentText = text;
                }

                onAccepted: root.context.tryUnlock()

                Connections {
                    target: root.context
                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                        passwordBox.forceActiveFocus();
                    }
                }
            }
        }
    }

    // subtle hint
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
        opacity: passwordBox.text.length > 0 ? 0.6 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }
}
