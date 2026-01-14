/*This one is like a control center something for wifi and stuff management*/
import QtQuick
import qs.Services.Theme
import qs.Services.Shapes
import qs.Modules.Hut.Powerski
import qs.Modules.Hut.Profile
import qs.Modules.Hut.Warsa

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
        width: contentLoader.item ? contentLoader.item.implicitWidth + 48 : 280
        height: isHovered ? (contentLoader.item ? contentLoader.item.implicitHeight + 48 : 140) : 1
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

        Behavior on width {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
            anchors.leftMargin: 15
            active: false
            asynchronous: true

            sourceComponent: Item {
                id: contentItem
                visible: root.isHovered
                implicitWidth: Math.max(profileComponent.implicitWidth, warsaComponent.implicitWidth, powerskiComponent.implicitWidth)
                implicitHeight: mainContent.implicitHeight

                property real contentOpacity: root.isHovered ? 1 : 0
                property real contentTranslateY: root.isHovered ? 0 : -20

                Behavior on contentOpacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on contentTranslateY {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                opacity: contentOpacity
                transform: Translate {
                    y: contentTranslateY
                }

                Column {
                    id: mainContent
                    spacing: 16

                    Profile {
                        id: profileComponent
                    }
                    Warsa {
                        id: warsaComponent
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Powerski {
                        id: powerskiComponent
                        anchors.horizontalCenter: parent.horizontalCenter
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
