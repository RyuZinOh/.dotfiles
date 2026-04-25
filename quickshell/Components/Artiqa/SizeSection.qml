pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Rectangle {
    id: sizeSection

    property real currentSize: 2.0
    signal sizeSelected(real size)
    signal dropdownToggled(bool open, real globalX, real globalY)

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
        radius: sizeMouse.containsMouse ? 26 : 8
        color: sizeMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent"
        border.color: sizeMouse.containsMouse ? Theme.outlineVariant : "transparent"
        border.width: sizeMouse.containsMouse ? 1 : 0
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
            text: sizeSection.currentSize
            color: Theme.onSurface
            font.pixelSize: 24
            font.weight: Font.Bold
        }

        MouseArea {
            id: sizeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                var pt = sizeSection.mapToItem(null, sizeSection.width / 2, 0);
                sizeSection.dropdownToggled(true, pt.x, pt.y);
            }
        }
    }
}
