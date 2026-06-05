pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.Services.Theme
import qs.Configuration.Screenshot

Item {
    id: root
    anchors.fill: parent
    focus: true

    Component.onCompleted: root.forceActiveFocus()
    Keys.onEscapePressed: ScreenshotConfig.dismissPreview()

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
        id: celestialSystem
        anchors.centerIn: parent

        property real padding: 24
        property real maxImgW: root.width * 0.8 - padding * 2
        property real maxImgH: root.height * 0.7 - padding * 2

        property real rawImgW: previewImage.implicitWidth > 0 ? previewImage.implicitWidth : 424
        property real rawImgH: previewImage.implicitHeight > 0 ? previewImage.implicitHeight : 280

        property real scaleFactor: Math.min(1.0, maxImgW / rawImgW, maxImgH / rawImgH)

        width: rawImgW * scaleFactor + padding * 2
        height: rawImgH * scaleFactor + padding * 2 + 72

        Rectangle {
            id: moonCard
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
                anchors.margins: celestialSystem.padding
                fillMode: Image.PreserveAspectFit
                cache: false
                smooth: true
                antialiasing: true
            }
        }

        Row {
            id: satelliteRow
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 32

            Repeater {
                model: [
                    {
                        icon: "\uf0c5",
                        isPrimary: false,
                        action: function () {
                            const tmp = "/tmp/qs_copy_tmp.png";
                            Quickshell.execDetached(["sh", "-c", "magick " + ScreenshotConfig.previewPath + " " + tmp + " && wl-copy -t image/png < " + tmp + " ; rm " + tmp + " " + ScreenshotConfig.previewPath]);
                            ScreenshotConfig.dismissPreview();
                        }
                    },
                    {
                        icon: "\uea78",
                        isPrimary: true,
                        action: function () {
                            const ts = new Date().toISOString().replace(/[:.]/g, "-").replace("T", "_").slice(0, 19);
                            const dest = "/home/safalski/photos/screenshot_" + ts + ".png";
                            Quickshell.execDetached(["sh", "-c", "magick " + ScreenshotConfig.previewPath + " " + dest + " && rm " + ScreenshotConfig.previewPath]);
                            ScreenshotConfig.dismissPreview();
                        }
                    }
                ]

                delegate: Item {
                    width: 52
                    height: 52

                    required property var modelData

                    Rectangle {
                        anchors.fill: parent
                        radius: 26
                        color: modelData.isPrimary ? (btn.containsMouse ? Theme.primaryColor : Theme.surfaceContainerHighest) : (btn.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                        border.color: modelData.isPrimary ? "transparent" : (btn.containsMouse ? Theme.outlineColor : Theme.outlineVariant)
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
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: 18
                            color: (modelData.isPrimary && btn.containsMouse) ? Theme.onPrimary : Theme.textColor

                            Behavior on color {
                                ColorAnimation {
                                    duration: 300
                                }
                            }
                        }

                        MouseArea {
                            id: btn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.action()
                        }
                    }
                }
            }
        }
    }
}
