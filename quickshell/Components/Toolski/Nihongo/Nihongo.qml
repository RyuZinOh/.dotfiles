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

        Row {
            width: parent.width
            height: 40
            spacing: 0

            Repeater {
                model: root.tabs

                Rectangle {
                    width: parent.width / root.tabs.length
                    height: parent.height
                    color: "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: modelData === root.currentTab ? parent.width * 0.6 : parent.width * 0.3
                        height: 2
                        color: Theme.onSurface
                        opacity: modelData === root.currentTab ? 1.0 : 0.3
                        radius: 1

                        Behavior on width {
                            SpringAnimation {
                                spring: 3.0
                                damping: 0.4
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: modelData === root.currentTab ? Theme.onSurface : Theme.onSurfaceVariant
                        font.pixelSize: 13
                        font.weight: modelData === root.currentTab ? Font.Bold : Font.Normal

                        scale: modelData === root.currentTab ? 1.0 : 0.95

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Behavior on scale {
                            SpringAnimation {
                                spring: 3.0
                                damping: 0.4
                            }
                        }
                    }

                    TapHandler {
                        onTapped: root.currentTab = modelData
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
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
                            text: modelData.kanji
                            color: Theme.onSurface
                            font.pixelSize: 38
                            font.family: "Noto Sans CJK JP"
                            font.weight: Font.Medium
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.meaning
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
