import QtQuick
import qs.Services.Theme

Rectangle {
    id: sizeSection

    property real currentSize: 2.0
    signal sizeSelected(real size)

    width: 100
    height: 64
    radius: 12
    color: Theme.surfaceContainerLow
    border.color: Theme.outlineVariant
    border.width: 1

    Rectangle {
        id: sizeButton
        anchors.centerIn: parent
        width: 84
        height: 52
        radius: sizeDropdown.visible ? 26 : (sizeMouse.containsMouse ? 26 : 8)
        color: sizeDropdown.visible ? Theme.primaryContainer : (sizeMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent")
        border.color: sizeDropdown.visible ? Theme.primaryColor : (sizeMouse.containsMouse ? Theme.outlineVariant : "transparent")
        border.width: sizeDropdown.visible ? 2 : (sizeMouse.containsMouse ? 1 : 0)
        scale: sizeMouse.pressed ? 0.95 : 1.0

        Behavior on radius {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: 150
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
            }
        }

        Text {
            anchors.centerIn: parent
            text: currentSize
            color: sizeDropdown.visible ? Theme.onPrimaryContainer : Theme.onSurface
            font.pixelSize: 24
            font.weight: Font.Bold

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        MouseArea {
            id: sizeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                sizeDropdown.visible = !sizeDropdown.visible;
            }
        }
    }

    Rectangle {
        id: sizeDropdown
        visible: false
        anchors.bottom: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 8

        width: 84
        height: sizeColumn.height + 16
        radius: 12
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1

        opacity: visible ? 1 : 0
        scale: visible ? 1 : 0.95

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }

        Column {
            id: sizeColumn
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: [2, 4, 6, 8, 10]

                delegate: Rectangle {
                    width: 68
                    height: 36
                    radius: currentSize === modelData ? 18 : 8
                    color: currentSize === modelData ? Theme.primaryContainer : (sizeItemMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent")
                    border.color: currentSize === modelData ? Theme.primaryColor : (sizeItemMouse.containsMouse ? Theme.outlineVariant : "transparent")
                    border.width: currentSize === modelData ? 2 : (sizeItemMouse.containsMouse ? 1 : 0)
                    scale: sizeItemMouse.pressed ? 0.95 : (sizeItemMouse.containsMouse ? 1.05 : 1.0)

                    Behavior on radius {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutBack
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: currentSize === modelData ? Theme.onPrimaryContainer : Theme.onSurface
                        font.pixelSize: 18
                        font.weight: currentSize === modelData ? Font.Bold : Font.Medium

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        id: sizeItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            sizeSection.sizeSelected(modelData);
                            sizeDropdown.visible = false;
                        }
                    }
                }
            }
        }
    }
}
