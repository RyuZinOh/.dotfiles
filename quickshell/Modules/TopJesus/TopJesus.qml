import QtQuick
// import Qt5Compat.GraphicalEffects
import qs.Services.Shapes
import qs.Services.Theme
import qs.Modules.TopJesus.Wow
import qs.Modules.TopJesus.ControlRoom
import qs.Modules.TopJesus.Statuski

//[If you to use these go to respected Modules and Backup those .bak files according to readme]
// import qs.Modules.TopJesus.Timerchan
// import qs.Modules.TopJesus.Streaks
import qs.Services.Music

Item {
    id: root

    implicitWidth: popout.implicitWidth
    implicitHeight: popout.implicitHeight
    width: implicitWidth
    height: implicitHeight

    property bool isHovered: false
    property bool isPinned: false
    property int activeTab: 1 // default is 1 -> Status component
    property real targetWidth: 400

    readonly property var tabs: [
        {
            name: "Control",
            component: controlRoomComponent
        },
        {
            name: "Status",
            component: statusComponent
        },
        {
            name: "Wow",
            component: wowComponent
        },
        // {
        //     name: "TimerChan",
        //     component: timerComponent
        // },
        // // {
        //     name: "GitHub",
        //     component: githubComponent
        // },
        {
            name: "Music",
            component: musicComponent
        },
    ]
    // was testing but creates a good background dropshadow somehow lol
    // FastBlur {
    //     anchors.fill: popout
    //     source: popout
    //     radius: 24
    //     transparentBorder: true
    // }
    PopoutShape {
        id: popout
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        implicitWidth: targetWidth
        implicitHeight: (isHovered || isPinned) ? (tabBar.height + 8 + contentArea.height + 40) : 0.1

        width: implicitWidth
        height: implicitHeight

        style: 1
        alignment: 0
        radius: 20
        color: Theme.surfaceContainer
        visible: (isHovered || isPinned) || heightAnimation.running

        Behavior on height {
            NumberAnimation {
                id: heightAnimation
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

        Behavior on width {
            enabled: isHovered || isPinned
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 15
            visible: isHovered || isPinned
            clip: true

            Item {
                id: tabBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 32

                Item {
                    id: tabsContainer
                    anchors.centerIn: parent
                    width: childrenRect.width
                    height: parent.height

                    Row {
                        id: tabRow
                        spacing: 25
                        height: parent.height

                        Repeater {
                            id: tabRepeater
                            model: root.tabs

                            Item {
                                id: tabButton
                                width: tabLabel.width + 20
                                height: tabRow.height

                                readonly property bool isActive: root.activeTab === index
                                readonly property string tabName: modelData.name

                                Text {
                                    id: tabLabel
                                    anchors.centerIn: parent
                                    text: tabButton.tabName
                                    color: tabButton.isActive ? Theme.onSurface : Theme.onSurfaceVariant
                                    font.pixelSize: 13
                                    font.weight: tabButton.isActive ? Font.Medium : Font.Normal
                                    font.family: "CaskaydiaCove NF"
                                    opacity: tabButton.isActive ? 1.0 : 0.5

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 200
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.activeTab = index;
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: indicator
                        height: 3
                        radius: 50
                        color: Theme.primaryColor

                        property real targetX: 0
                        property real targetWidth: 0

                        x: targetX
                        width: targetWidth

                        Component.onCompleted: {
                            updateIndicator();
                        }

                        Connections {
                            target: root
                            function onActiveTabChanged() {
                                indicator.updateIndicator();
                            }
                        }

                        Connections {
                            target: tabRepeater
                            function onItemAdded() {
                                Qt.callLater(indicator.updateIndicator);
                            }
                        }

                        function updateIndicator() {
                            if (tabRepeater.count === 0) {
                                return;
                            }

                            const activeItem = tabRepeater.itemAt(root.activeTab);
                            if (!activeItem) {
                                return;
                            }

                            targetX = activeItem.x;
                            targetWidth = activeItem.width;
                        }

                        Behavior on targetX {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on targetWidth {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                // pin button in case u want a beauty
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    height: 28
                    radius: 6
                    color: pinMouseArea.containsMouse ? Theme.surfaceBright : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: root.isPinned ? "󰐃" : "󰐃"
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 16
                        color: root.isPinned ? Theme.primaryColor : Theme.onSurfaceVariant
                        rotation: root.isPinned ? 0 : 45

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                        Behavior on rotation {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: pinMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.isPinned = !root.isPinned;
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }

            Item {
                id: contentArea
                anchors.top: tabBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: contentLoader.item ? contentLoader.item.implicitHeight : 160
                clip: true

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    opacity: 0
                    //unload inactive tabs to save memory
                    active: root.isHovered || root.isPinned // probably make it true so that timerchan and other conponent stays active but ye [i dont need it for some reason cause I am not using other stuff beside controlroom and overview so]

                    sourceComponent: root.tabs[root.activeTab].component

                    onLoaded: {
                        if (item) {
                            const newWidth = item.implicitWidth || 400;
                            root.targetWidth = newWidth;
                        }
                        fadeIn.restart();
                    }

                    NumberAnimation {
                        id: fadeIn
                        target: contentLoader
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuad
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

    Component {
        id: controlRoomComponent
        ControlRoom {}
    }

    Component {
        id: wowComponent
        Wow {
            useScreencopyLivePreview: false
        }
    }
    Component {
        id: statusComponent
        Statuski {}
    }
    // Component {
    //     id: timerComponent
    //     Timerchan {}
    // }
    //
    // Component {
    //     id: githubComponent
    //     Github {}
    // }
    //
    Component {
        id: musicComponent
        Controller {}
    }
}
