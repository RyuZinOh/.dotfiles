import QtQuick
import qs.Services.Theme

Rectangle {
    id: colorSection

    property string currentColor: Theme.primaryColor
    signal colorSelected(string color)

    width: 250
    height: 64
    radius: 12
    color: Theme.surfaceContainerLow
    border.color: Theme.outlineVariant
    border.width: 1

    Row {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: [Theme.errorColor, Theme.secondaryColor, Theme.primaryColor, Theme.tertiaryColor, Theme.onSurface, Theme.surfaceContainerHighest]

            delegate: Rectangle {
                id: colorButton
                width: 32
                height: 32

                property bool isActive: currentColor.toString().toUpperCase() === modelData.toString().toUpperCase()

                radius: (isActive || colorMouse.containsMouse) ? 16 : 6
                color: modelData
                border.color: isActive ? Theme.primaryColor : (colorMouse.containsMouse ? Theme.outlineVariant : "transparent")
                border.width: isActive ? 3 : (colorMouse.containsMouse ? 2 : 0)
                scale: colorMouse.pressed ? 0.9 : ((colorMouse.containsMouse || isActive) ? 1.1 : 1.0)

                Behavior on radius {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on border.width {
                    NumberAnimation {
                        duration: 150
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutBack
                    }
                }

                MouseArea {
                    id: colorMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorSection.colorSelected(modelData);
                    }
                }
            }
        }
    }
}
