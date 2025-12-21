import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Services.Shapes
import qs.Modules.Setski.Wallski
import qs.Services.Theme

// import Qt5Compat.GraphicalEffects

Item {
    id: root

    //dynamic dimensions based on content
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight

    property bool isHovered: false
    /*
    [0 => wallski] Never Increase the default size greater than the other else
    It might auto hide when switching to lesser width one!!
    */
    property int currentTab: 0

    //storing last known width
    property real currentContentWidth: parent.width
    property bool isRefreshing: false

    signal wallpaperChanged(string path)

    onIsHoveredChanged: {
        if (!isHovered && contentLoader.item) {
            if (currentTab === 0 && contentLoader.item.isHovered !== undefined) {
                contentLoader.item.isHovered = false;
            }
        }
    }

/* I wanted to run script from UI for the ease, so adding this*/
    Process {
        id: bamProcess
        command: ["/bin/bash", "/home/safal726/.dotfiles/quickshell/Scripts/bam.sh"]
        running: false

        onExited: {
            isRefreshing = false;
        }
    }

    function runBamScript() {
        isRefreshing = true;
        bamProcess.running = true;
    }

    // FastBlur {
    //     anchors.fill: content
    //     source: popout
    //     radius: 24
    //     transparentBorder: true
    // }
    PopoutShape {
        id: content
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        //width based on active component
        implicitWidth: {
            if (!root.isHovered) {
                return currentContentWidth;
            }
            if (!contentLoader.item) {
                return 999; //fallback
            }
            const newW = contentLoader.item.implicitWidth || 999;
            currentContentWidth = newW;
            return newW;
        }

        //height based on hover state and content
        implicitHeight: {
            if (!root.isHovered) {
                return 0.1;
            }
            const tabsHeight = 28;
            const spacing = 8;
            const margins = 30;
            const contentHeight = contentLoader.item ? (contentLoader.item.implicitHeight || 200) : 200;
            return tabsHeight + spacing + contentHeight + margins;
        }
        width: implicitWidth
        height: implicitHeight
        alignment: 4
        radius: 20
        color: Theme.surfaceContainer

        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuad
            }
        }
        Behavior on width {
            enabled: root.isHovered // only animate width when hovered
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutQuad
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8
            visible: root.isHovered

            // tabs
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 28

                Row {
                    id: tabRow
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 25

                    Repeater {
                        id: tabRepeater
                        model: ["Wallpapers"]

                        Item {
                            id: tabItem
                            width: tabText.width + 10
                            height: 28

                            property bool isActive: currentTab === index

                            Text {
                                id: tabText
                                anchors.centerIn: parent
                                text: modelData
                                color: tabItem.isActive ? Theme.onSurface : Theme.dimColor
                                font.pixelSize: 13
                                font.weight: tabItem.isActive ? Font.Medium : Font.Normal
                                font.family: "CaskaydiaCove NF"
                                opacity: tabItem.isActive ? 1.0 : 0.5

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
                                onClicked: currentTab = index
                            }
                        }
                    }
                }

                //refresh
                Text {
                    id: refreshIcon
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰑐"
                    color: refreshMouse.containsMouse ? Theme.primaryColor : Theme.dimColor
                    font.pixelSize: 32
                    font.family: "CaskaydiaCove NF"

                    RotationAnimator {
                        target:refreshIcon
                        from: 0
                        to: 360
                        duration: 400
                        loops: Animation.Infinite
                        running: isRefreshing
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        anchors.margins: -5
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !isRefreshing
                        onClicked: runBamScript()
                    }
                }

                Rectangle {
                    id: activeIndicator
                    height: 2
                    color: Theme.primaryColor

                    property Item activeTab: tabRepeater.count > 0 ? tabRepeater.itemAt(currentTab) : null

                    x: activeTab ? activeTab.x + (activeTab.width - width) / 2 : 0
                    width: activeTab ? activeTab.width : 0

                    Behavior on x {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }
                    // just a jumpback when switching
                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            //content
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: contentLoader.item ? contentLoader.item.implicitHeight : 200

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    opacity: 0
                    //unload inactive tabs to save memory
                    active: root.isHovered // probably make it true so that timerchan stays active but ye [i dont need it for some reason]
                    sourceComponent: {
                        switch (currentTab) {
                        case 0:
                            return wallskiComponent;
                        // case 1:
                        // return hllComponent;
                        // case 2:
                        //     return wowComponent;
                        default:
                            return null;
                        }
                    }
                    onLoaded: {
                        fadeInAnimation.restart();
                        if (currentTab === 0 && item) {
                            item.isHovered = Qt.binding(function () {
                                return root.isHovered && currentTab === 0;
                            });
                            item.wallpaperChanged.connect(root.wallpaperChanged);
                        }
                    }
                    NumberAnimation {
                        id: fadeInAnimation
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
        onHoveredChanged: root.isHovered = hovered
    }

    Component {
        id: wallskiComponent
        Wallski {}
    }
}
