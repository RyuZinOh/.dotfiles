/*This one is like a control center something for wifi and stuff management*/
pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import qs.Services.Shapes
import "./Profile/"
// import "./Evernight/"
import "./Warsa/"
import "./Areuok/"

Item {
    id: root
    anchors.top: parent.top
    anchors.right: parent.right

    width: content.width
    height: content.height

    property bool isHovered: false

    onIsHoveredChanged: {
        if (!root.isHovered) {
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
        // container aint loaded so liner warning exists...
        height: {
            if (!root.isHovered)
                return 0.1;
            if (contentLoader.status === Loader.Ready) {
                let loadedItem = contentLoader.item as Item;
                if (loadedItem) {
                    return loadedItem.implicitHeight + 48;
                }
            }
            return 140;
        }
        visible: content.height > 1
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
            anchors{
              leftMargin: 20
              rightMargin: 5
            }
            active: false
            asynchronous: true
            clip: true

            sourceComponent: Component {
                Item {
                    id: contentItem
                    visible: root.isHovered
                    implicitWidth: {
                        let maxWidth = profileComponent.implicitWidth;
                        let areuokItem = areuokLoader.item as Item;
                        let warsaItem = warsaLoader.item as Item;
                        // let evernightItem = evernightLoader.item as Item;

                        if (areuokItem) {
                            maxWidth = Math.max(maxWidth, areuokItem.implicitWidth);
                        }
                        // if (evernightItem) {
                        //     maxWidth = Math.max(maxWidth, evernightItem.implicitWidth);
                        // }
                        if (warsaItem) {
                            maxWidth = Math.max(maxWidth, warsaItem.implicitWidth);
                        }
                        return maxWidth;
                    }
                    implicitHeight: mainContent.implicitHeight + 20

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

                    opacity: contentItem.contentOpacity
                    transform: Translate {
                        y: contentItem.contentTranslateY
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
                        // [I currently don't need this...]
                        // Loader {
                        //     id: evernightLoader
                        //     anchors.horizontalCenter: parent.horizontalCenter
                        //     active: root.isHovered
                        //     asynchronous: true
                        //     sourceComponent: Component {
                        //         Evernight {}
                        //     }
                        // }
                        Loader {
                            id: warsaLoader
                            anchors.horizontalCenter: parent.horizontalCenter
                            active: root.isHovered
                            asynchronous: true
                            sourceComponent: Component {
                                Warsa {}
                            }
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            root.isHovered = hoverHandler.hovered;
        }
    }
}
