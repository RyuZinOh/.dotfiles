pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property string source
    property bool pan: false

    anchors.fill: parent
    clip: true

    Image {
        id: wallpaper

        readonly property bool isPannable: root.pan && (implicitWidth / implicitHeight) > (root.width / root.height) * 1.05
        readonly property real fillWidth: isPannable ? implicitWidth * (root.height / implicitHeight) : root.width

        property real mouseXNorm: 0.5

        height: root.height
        width: wallpaper.fillWidth
        source: root.source
        cache: false
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: root.width
        sourceSize.height: root.height
        smooth: true
        mipmap: true

        x: wallpaper.isPannable ? -(wallpaper.fillWidth - root.width) * wallpaper.mouseXNorm : 0

        Behavior on x {
            enabled: wallpaper.isPannable
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: wallpaper.isPannable
            propagateComposedEvents: true
            onMouseXChanged: if (wallpaper.isPannable) {
                wallpaper.mouseXNorm = mouseX / width;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.7
    }
}
