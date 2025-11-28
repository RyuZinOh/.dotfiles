import QtQuick
import QtQuick.Layouts
import qs.Services.Shapes
import qs.Modules.Setski.Wallski
import qs.Modules.Setski.Hll
import qs.Modules.Setski.Wow

Item {
    id: root
    height: content.height

    property bool isHovered: false
    property int currentTab: 0

    signal wallpaperChanged(string path)

    onIsHoveredChanged: {
        if (!isHovered && contentLoader.item) {
            if (currentTab === 0 && contentLoader.item.isHovered !== undefined) {
                contentLoader.item.isHovered = false;
            }
        }
    }

    PopoutShape {
        id: content
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: root.isHovered ? 330 : 0.1
        style: 1
        alignment: 4
        radius: 20
        color: "black"

        Behavior on height {
            NumberAnimation {
                duration: 400
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
                    anchors.fill: parent
                    spacing: 25

                    Repeater {
                        id: tabRepeater
                        model: ["Wallpapers", "Hello", "Wow"]

                        Item {
                            id: tabItem
                            width: tabText.width + 10
                            height: 28

                            property bool isActive: currentTab === index

                            Text {
                                id: tabText
                                anchors.centerIn: parent
                                text: modelData
                                color: tabItem.isActive ? "white" : "gray"
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

                Rectangle {
                    id: activeIndicator
                    height: 2
                    color: "white"

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

                Loader {
                    id: contentLoader
                    anchors.fill: parent

                    sourceComponent: {
                        switch (currentTab) {
                        case 0:
                            return wallskiComponent;
                        case 1:
                            return hllComponent;
                        case 2:
                            return wowComponent;
                        default:
                            return null;
                        }
                    }

                    onLoaded: {
                        if (currentTab === 0 && item) {
                            item.isHovered = Qt.binding(() => root.isHovered && currentTab === 0);
                            item.wallpaperChanged.connect(root.wallpaperChanged);
                        }
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

    Component {
        id: hllComponent
        Hll {}
    }

    Component {
        id: wowComponent
        Wow {}
    }
}
