pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.Services.Theme
import qs.Configuration.Screenshot

Item {
    id: root
    anchors.fill: parent
    focus: true

    property string activeAction: ""

    Component.onCompleted: root.forceActiveFocus()
    Keys.onEscapePressed: ScreenshotConfig.dismissPreview()

    // qmllint disable signal-handler-parameters
    Process {
        id: actionProc
        onExited: {
            root.activeAction = "";
            ScreenshotConfig.dismissPreview();
        }
    }
    // qmllint enable signal-handler-parameters

    function executeAction(type) {
        root.activeAction = type;
        if (type === "copy") {
            actionProc.exec(["sh", "-c", "magick " + ScreenshotConfig.previewPath + " jpeg:- | wl-copy -t image/jpeg && rm " + ScreenshotConfig.previewPath]);
        } else if (type === "save") {
            const ts = new Date().toISOString().replace(/[:.]/g, "-").replace("T", "_").slice(0, 19);
            const dest = "/home/safalski/photos/screenshot_" + ts + ".jpg";
            actionProc.exec(["sh", "-c", "magick " + ScreenshotConfig.previewPath + " " + dest + " && rm " + ScreenshotConfig.previewPath]);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.backgroundColor
        opacity: 0.85

        MouseArea {
            anchors.fill: parent
            onClicked: ScreenshotConfig.dismissPreview()
        }
    }

    Item {
        id: card
        anchors.centerIn: parent

        property real padding: 24
        property real maxImgW: root.width * 0.8 - card.padding * 2
        property real maxImgH: root.height * 0.7 - card.padding * 2
        property real rawImgW: previewImage.implicitWidth > 0 ? previewImage.implicitWidth : 424
        property real rawImgH: previewImage.implicitHeight > 0 ? previewImage.implicitHeight : 280
        property real scaleFactor: Math.min(1.0, card.maxImgW / card.rawImgW, card.maxImgH / card.rawImgH)

        width: card.rawImgW * card.scaleFactor + card.padding * 2
        height: card.rawImgH * card.scaleFactor + card.padding * 2 + 72

        Rectangle {
            width: parent.width
            height: parent.height - 72
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 28
            color: Theme.surfaceColor
            border.color: Theme.outlineVariant
            border.width: 1
            layer.enabled: true

            Image {
                id: previewImage
                source: "file://" + ScreenshotConfig.previewPath
                anchors.fill: parent
                anchors.margins: card.padding
                fillMode: Image.PreserveAspectFit
                cache: false
                smooth: true
                antialiasing: true
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 32

            Repeater {
                model: [
                    {
                        icon: "\uf0c5",
                        isPrimary: false,
                        actionType: "copy"
                    },
                    {
                        icon: "\uea78",
                        isPrimary: true,
                        actionType: "save"
                    }
                ]

                delegate: Item {
                    id: delegateItem
                    width: 52
                    height: 52

                    required property var modelData

                    Rectangle {
                        id: btnRect
                        anchors.fill: parent
                        radius: 26
                        color: delegateItem.modelData.isPrimary ? (btn.containsMouse ? Theme.primaryColor : Theme.surfaceContainerHighest) : (btn.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                        border.color: delegateItem.modelData.isPrimary ? "transparent" : (btn.containsMouse ? Theme.outlineColor : Theme.outlineVariant)
                        border.width: 1
                        scale: btn.containsMouse ? 1.08 : 1.0

                        Behavior on color {
                            ColorAnimation {
                                duration: 300
                                easing.type: Easing.OutSine
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutElastic
                            }
                        }
                        Behavior on border.color {
                            ColorAnimation {
                                duration: 300
                            }
                        }

                        Text {
                            id: btnIcon
                            anchors.centerIn: parent
                            text: delegateItem.modelData.icon
                            font.pixelSize: 18
                            color: (delegateItem.modelData.isPrimary && btn.containsMouse) ? Theme.onPrimary : Theme.textColor

                            Behavior on color {
                                ColorAnimation {
                                    duration: 300
                                }
                            }

                            transform: Rotation {
                                origin.x: btnIcon.width / 2
                                origin.y: btnIcon.height / 2
                                angle: 0
                                NumberAnimation on angle {
                                    from: 0
                                    to: 360
                                    duration: 700
                                    loops: Animation.Infinite
                                    running: actionProc.running && root.activeAction === delegateItem.modelData.actionType
                                    easing.type: Easing.Linear
                                }
                            }
                        }

                        MouseArea {
                            id: btn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.executeAction(delegateItem.modelData.actionType)
                        }
                    }
                }
            }
        }
    }
}
