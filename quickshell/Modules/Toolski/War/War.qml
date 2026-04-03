import QtQuick
import Kraken
import qs.Services.Theme

/*
read-> https://safallama.com.np/posts/quests/
 */
Item {
    id: root
    width: 360
    implicitHeight: mainCol.implicitHeight

    property string warFile: "/home/safalski/.cache/safalQuick/todaywarpick.json"
    property var war: ({})
    property bool active: false
    signal warLoaded
    Kraken {
        id: warReader
        filePath: root.warFile

        onDataLoaded: {
            root.war = warReader.data;
            root.active = true;
            root.warLoaded();
        }
    }

    Column {
        id: mainCol
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 24
            topMargin: 24
        }
        spacing: 0
        Row {
            width: parent.width
            spacing: 8

            Column {
                spacing: 4
                width: parent.width - dateChip.width - 8

                Text {
                    text: "Daily Coding War"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.letterSpacing: 1.1
                    color: Theme.onSurfaceVariant
                }

                Text {
                    text: "Today's challenge"
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    color: Theme.onSurface
                }
            }

            Rectangle {
                id: dateChip
                height: 26
                width: dateText.width + 20
                radius: 8
                color: Theme.surfaceContainer
                border.width: 0.5
                border.color: Theme.outlineVariant
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: dateText
                    anchors.centerIn: parent
                    text: root.war.date || Qt.formatDate(new Date(), "MMM d, yyyy")
                    font.pixelSize: 11
                    color: Theme.onSurfaceVariant
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 0.5
            color: Theme.outlineVariant
            opacity: 0.5
            anchors.topMargin: 16
            anchors.bottomMargin: 16
            Rectangle {
                width: 1
                height: 16
                color: "transparent"
            }
        }

        Item {
            width: 1
            height: 16
        }

        Rectangle {
            id: challengeCard
            width: parent.width
            height: cardContent.implicitHeight + 36
            radius: 14
            color: Theme.surfaceContainer
            border.width: 0.5
            border.color: Theme.outlineVariant

            Column {
                id: cardContent
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 18
                }
                spacing: 10

                Text {
                    text: root.war.challenge?.title || "Loading..."
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: Theme.onSurface
                    width: parent.width
                    wrapMode: Text.Wrap
                    lineHeight: 1.35
                }

                Text {
                    text: root.war.challenge?.description || ""
                    font.pixelSize: 13
                    color: Theme.onSurfaceVariant
                    width: parent.width
                    wrapMode: Text.WordWrap
                    lineHeight: 1.55
                    visible: text.length > 0
                }

                Row {
                    spacing: 8
                    topPadding: 4

                    Rectangle {
                        height: 24
                        width: diffLabel.width + 16
                        radius: 6
                        color: Theme.tertiaryContainer

                        Text {
                            id: diffLabel
                            anchors.centerIn: parent
                            text: root.war.challenge?.difficulty || "N/A"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: Theme.onTertiaryContainer
                        }
                    }

                    Rectangle {
                        height: 24
                        width: langLabel.width + 16
                        radius: 6
                        color: Theme.secondaryContainer

                        Text {
                            id: langLabel
                            anchors.centerIn: parent
                            text: root.war.language || "N/A"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: Theme.onSecondaryContainer
                        }
                    }
                }
            }
        }

        Item {
            width: 1
            height: 4
        }
    }
}
