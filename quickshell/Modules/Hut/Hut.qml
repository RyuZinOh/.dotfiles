/*This one is like a control center something for wifi and stuff management*/
import QtQuick
import qs.Services.Theme
import qs.Services.Shapes
import qs.Modules.Hut.Powerski
import qs.Modules.Hut.Profile
import qs.Modules.Hut.Warsa
import qs.Modules.Hut.Evernight
import qs.Modules.Hut.Areuok

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
        interval: 500
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

        Loader {
            id: contentLoader
            anchors.fill: parent
            anchors.leftMargin: 15
            active: false
            asynchronous: true

            sourceComponent: Item {
                id: contentItem
                visible: root.isHovered
                implicitWidth: Math.max(profileComponent.implicitWidth, areuokLoader.item ? areuokLoader.item.implicitWidth : 0, evernightLoader.item ? evernightLoader.item.implicitWidth : 0, warsaLoader.item ? warsaLoader.item.implicitWidth : 0, powerskiLoader.item ? powerskiLoader.item.implicitWidth : 0)
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
                    Loader {
                        id: areuokLoader
                        anchors.horizontalCenter: parent.horizontalCenter
                        active: root.isHovered
                        asynchronous: true
                        sourceComponent: Component {
                            Areuok {}
                        }
                    }
                    Loader {
                        id: evernightLoader
                        anchors.horizontalCenter: parent.horizontalCenter
                        active: root.isHovered
                        asynchronous: true
                        sourceComponent: Component {
                            Evernight {}
                        }
                    }
                    Loader {
                        id: warsaLoader
                        anchors.horizontalCenter: parent.horizontalCenter
                        active: root.isHovered
                        asynchronous: true
                        sourceComponent: Component {
                            Warsa {}
                        }
                    }
                    Loader {
                        id: powerskiLoader
                        anchors.horizontalCenter: parent.horizontalCenter
                        active: root.isHovered
                        asynchronous: true
                        sourceComponent: Component {
                            Powerski {}
                        }
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
