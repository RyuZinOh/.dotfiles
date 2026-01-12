/*This one is like a control center something for wifi and stuff management*/
import QtQuick
import qs.Services.Theme
import qs.Services.Shapes

Item {
    id: root
    anchors.top: parent.top
    anchors.right: parent.right

    width: content.width
    height: content.height

    property bool isHovered: false

    onIsHoveredChanged: {
        if (!isHovered) {
            unloadTimer.start();
        } else {
            unloadTimer.stop();
            if (!contentLoader.active) {
                contentLoader.active = true;
            }
        }
    }

    Timer {
        id: unloadTimer
        interval: 400
        onTriggered: {
            if (!root.isHovered) {
                contentLoader.active = false;
            }
        }
    }

    PopoutShape {
        id: content
        anchors.right: parent.right
        anchors.top: parent.top
        width: 400
        height: isHovered ? 300 : 1
        alignment: 1
        radius: 20
        color: Theme.surfaceContainerLow
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
            anchors.margins: 10
            active: false
            asynchronous: true

            sourceComponent: Item {
                visible: root.isHovered

                Rectangle {
                    anchors.fill: parent
                    anchors{
                      leftMargin: 20
                      rightMargin: 0
                      topMargin: -15
                      bottomMargin: 10
                    }
                    color: Theme.surfaceContainer
                    radius: 12

                    Text {
                        anchors.centerIn: parent
                        text: "Hut Content"
                        color: Theme.onSurface
                        font.pixelSize: 16
                        font.family: "CaskaydiaCove NF"
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            root.isHovered = hovered;
        }
    }
}
