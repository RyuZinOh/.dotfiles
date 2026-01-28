pragma ComponentBehavior: Bound
import QtQuick
import Kraken
import qs.Services.Theme

Item {
    id: root

    property var characters: ({})
    property string currentTab: "Hiragana"
    readonly property var tabs: ["Hiragana", "Katakana", "Kanji"]

    Kraken {
        id: jsonReader
        filePath: Qt.resolvedUrl("../../../Assets/jlearn.json").toString().replace("file://", "")

        onDataLoaded: {
            var tempChars = {};
            for (var category in data) {
                tempChars[category] = Object.keys(data[category]).map(key => ({
                            kanji: key,
                            meaning: data[category][key]
                        }));
            }
            root.characters = tempChars;
        }
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Item {
            id: tabContainer
            width: parent.width
            height: 40

            Row {
                id: tabRow
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: root.tabs

                    Rectangle {
                        id: tabRect
                        required property string modelData
                        required property int index

                        width: tabRow.width / root.tabs.length
                        height: tabRow.height
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: tabRect.modelData
                            color: tabRect.modelData === root.currentTab ? Theme.onSurface : Theme.onSurfaceVariant
                            font.pixelSize: 13
                            font.weight: tabRect.modelData === root.currentTab ? Font.Bold : Font.Normal

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }

                        TapHandler {
                            onTapped: root.currentTab = tabRect.modelData
                        }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }

            Rectangle {
                id: activeIndicator
                width: 100
                height: 2
                color: Theme.onSurface
                radius: 1
                visible: tabRow.width > 0

                property bool isInitialized: false
                property bool layoutStable: false
                property int layoutStableCounter: 0
                property real lastTabWidth: 0

                property int currentIndex: root.tabs.indexOf(root.currentTab)
                property real tabWidth: tabRow.width > 0 ? tabRow.width / root.tabs.length : 0
                property real targetX: currentIndex >= 0 && tabWidth > 0 ? currentIndex * tabWidth + (tabWidth - width) / 2 : 0

                x: targetX
                y: tabContainer.height - height

                onTabWidthChanged: {
                    if (!layoutStable) {
                        var delta = Math.abs(tabWidth - lastTabWidth);
                        lastTabWidth = tabWidth;

                        if (delta < 0.01) {
                            layoutStableCounter++;

                            if (layoutStableCounter >= 3) {
                                layoutStable = true;
                                Qt.callLater(function () {
                                    isInitialized = true;
                                });
                            }
                        } else {
                            layoutStableCounter = 0;
                        }
                    }
                }

                Component.onCompleted: {
                    lastTabWidth = tabWidth;
                }

                Behavior on targetX {
                    enabled: activeIndicator.isInitialized && activeIndicator.layoutStable
                    SpringAnimation {
                        spring: 3.0
                        damping: 0.4
                    }
                }
            }
        }

        GridView {
            width: parent.width
            height: parent.height - 50
            cellWidth: width / 5
            cellHeight: 95
            clip: true
            model: root.characters[root.currentTab] || []

            boundsBehavior: Flickable.DragAndOvershootBounds

            delegate: Item {
                id: gridItem
                required property var modelData
                required property int index

                width: GridView.view.cellWidth
                height: GridView.view.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    color: Theme.surfaceContainerHighest
                    radius: 10
                    opacity: 0.85

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: gridItem.modelData?.kanji ?? ""
                            color: Theme.onSurface
                            font.pixelSize: 38
                            font.family: "Noto Sans CJK JP"
                            font.weight: Font.Medium
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: gridItem.modelData?.meaning ?? ""
                            color: Theme.onSurfaceVariant
                            font.pixelSize: 10
                            font.weight: Font.Normal
                        }
                    }
                }
            }
        }
    }
}
