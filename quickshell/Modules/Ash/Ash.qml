import QtQuick
import qs.Services.Theme

Item {
    id: ashRoot
    property bool isHovered: false

    readonly property int circleSize: 40
    readonly property int expandedWidth: 280
    readonly property int expandedHeight: 120

    implicitWidth: isHovered ? expandedWidth : circleSize
    implicitHeight: isHovered ? expandedHeight : circleSize

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Circle {
        anchors.fill: parent
        onIsHoveredChanged: ashRoot.isHovered = isHovered
    }
}
