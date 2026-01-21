import QtQuick
import Kraken
import qs.Services.Theme

/*
read-> https://safallama.com.np/posts/quests/
 */
Item {
    id: root
    width: 400
    height: 500

    property string warFile: "/home/safal726/.cache/safalQuick/todaywarpick.json"
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

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Column {
            anchors {
                fill: parent
                topMargin: 32
                leftMargin: 20
                rightMargin: 20
                bottomMargin: 20
            }
            spacing: 24

            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Daily Coding War"
                    color: Theme.primaryColor
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    layer.enabled: true
                    layer.smooth: true
                }

                Text {
                    text: root.war.date || new Date().toLocaleDateString()
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 13
                    opacity: 0.65
                    font.weight: Font.Medium
                }
            }

            Rectangle {
                width: parent.width
                height: 2
                radius: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop {
                        position: 0.5
                        color: Theme.outlineVariant
                    }
                    GradientStop {
                        position: 1.0
                        color: "transparent"
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 16
                visible: root.active
                opacity: root.active ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    text: "Today's Challenge"
                    color: Theme.primaryColor
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    opacity: 0.95
                }

                Rectangle {
                    width: parent.width
                    height: challengeContent.height + 36
                    radius: 14
                    color: Theme.surfaceContainer
                    border.color: Theme.primaryColor
                    border.width: 2

                    layer.enabled: true
                    layer.smooth: true

                    Column {
                        id: challengeContent
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 22
                        }
                        spacing: 14

                        Text {
                            text: root.war.challenge?.title || "Loading..."
                            color: Theme.onSurface
                            font.pixelSize: 19
                            font.weight: Font.Bold
                            width: parent.width
                            wrapMode: Text.Wrap
                            lineHeight: 1.3
                        }

                        Text {
                            text: root.war.challenge?.description || ""
                            color: Theme.onSurfaceVariant
                            font.pixelSize: 14
                            opacity: 0.87
                            wrapMode: Text.WordWrap
                            width: parent.width
                            lineHeight: 1.5
                        }

                        Row {
                            spacing: 12

                            Rectangle {
                                height: 26
                                width: diffText.width + 18
                                radius: 7
                                color: Theme.tertiaryContainer

                                Text {
                                    id: diffText
                                    anchors.centerIn: parent
                                    text: root.war.challenge?.difficulty || "N/A"
                                    color: Theme.onTertiaryContainer
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                            }

                            Rectangle {
                                height: 26
                                width: langText.width + 18
                                radius: 7
                                color: Theme.secondaryContainer

                                Text {
                                    id: langText
                                    anchors.centerIn: parent
                                    text: root.war.language || "N/A"
                                    color: Theme.onSecondaryContainer
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
