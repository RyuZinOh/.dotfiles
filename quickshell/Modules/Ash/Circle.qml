import QtQuick
import qs.Services.Theme

Rectangle {
    id: circleRoot
    property bool isHovered: hoverHandler.hovered

    anchors.fill: parent
    radius: isHovered ? 16 : width / 2
    color: Theme.surfaceContainer
    border.color: Theme.outlineVariant
    border.width: 2
    clip: true

    Behavior on radius {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 300
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        anchors.centerIn: parent
        width: 12
        height: 12
        radius: 6
        color: Theme.primaryColor
        opacity: isHovered ? 0 : 1
        visible: !isHovered

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 12
        opacity: isHovered ? 1 : 0
        scale: isHovered ? 1 : 0.7
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Hello Safal,"
            font.pixelSize: 16
            font.weight: Font.Medium
            color: Theme.onSurface
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Hope you're ok.."
            font.pixelSize: 14
            color: Theme.dimColor
        }
    }
}
