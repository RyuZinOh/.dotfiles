pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.Services.Theme

Rectangle {
    id: root
    required property var context

    color: Theme.backgroundColor

    Image {
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/.cache/safalQuick/bg.jpg"
        fillMode: Image.PreserveAspectCrop

        Rectangle {
            anchors.fill: parent
            color: Theme.backgroundColor
            opacity: 0.7
        }
    }

    Text {
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
        color: Theme.primaryFixed
        opacity: 0.95

        text: passwordBox.text.length > 0 ? "hell yea!!" : "Do you love red panda?"

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
                    to: 0.95
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
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 20
                    height: parent.height + 20
                    radius: width / 2
                    color: "transparent"
                    border.color: root.context.showFailure ? Theme.errorColor : Theme.primaryFixedDim
                    border.width: 1
                    opacity: 0.3
                }

                Repeater {
                    model: passwordBox.text.length

                    delegate: Text {
                        id: kanjiText
                        required property int index

                        property real angle: (index * 360 / Math.max(passwordBox.text.length, 1))
                        property real distance: 120 + (index % 2) * 20
                        property var kanjis: ['雷', '龍', '火', '水', '風', '月', '星', '夢', '侍', '魂', '剣', '神', '虎', '鳳', '雲', '霊']

                        visible: true

                        x: 100 + Math.cos(angle * Math.PI / 180) * distance - width / 2
                        y: 100 + Math.sin(angle * Math.PI / 180) * distance - height / 2

                        text: kanjis[index % kanjis.length]

                        font.pointSize: 18 + (index % 2) * 4
                        color: Theme.primaryFixedDim
                        opacity: 0.35 - (index % 2) * 0.08
                        style: Text.Outline
                        styleColor: Theme.backgroundColor

                        transform: Rotation {
                            origin.x: 0
                            origin.y: 0
                            angle: kanjiText.index * 20

                            RotationAnimation on angle {
                                running: true
                                loops: Animation.Infinite
                                from: kanjiText.index * 20
                                to: kanjiText.index * 20 + 360
                                duration: 12000 + (kanjiText.index * 300)
                            }
                        }
                    }
                }

                Rectangle {
                    id: pfpContainer
                    anchors.fill: parent
                    radius: width / 2
                    color: root.context.showFailure ? Theme.errorColor : Theme.primaryContainer

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
                        color: Theme.onPrimaryContainer
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

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: root.context.showFailure ? Theme.errorColor : Theme.primaryFixed
                    border.width: 3
                }
            }

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

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 60
        }
        text: "Press Enter to unlock"
        font.pointSize: 11
        font.weight: Font.Light
        color: Theme.primaryFixedDim
        opacity: passwordBox.text.length > 0 ? 0.7 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }
}
