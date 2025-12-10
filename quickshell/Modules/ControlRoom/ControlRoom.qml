import QtQuick
import QtQuick.Layouts
import qs.Services.Shapes

Item {
    id: root
    width: content.width
    height: 300

    property bool isHovered: false

    readonly property color bg: "black"
    readonly property color textPrimary: "white"
    readonly property color accent: "blue"

    PopoutShape {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        width: 400
        height: root.isHovered ? 180 : 0.1

        style: 1
        alignment: 0
        radius: 20
        color: root.bg

        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 20
            opacity: root.isHovered ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 15

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 2
                    rowSpacing: 12
                    columnSpacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1a1a1a"
                        radius: 15

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "󰖩"
                                color: root.accent
                                font.pixelSize: 32
                                font.family: "CaskaydiaCove NF"
                            }

                            Text {
                                text: "WiFi"
                                color: root.textPrimary
                                font.pixelSize: 12
                                font.family: "CaskaydiaCove NF"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: console.log("WiFi clicked!")
                            onEntered: parent.color = "#252525"
                            onExited: parent.color = "#1a1a1a"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1a1a1a"
                        radius: 15

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "󰂯"
                                color: root.accent
                                font.pixelSize: 32
                                font.family: "CaskaydiaCove NF"
                            }

                            Text {
                                text: "Bluetooth"
                                color: root.textPrimary
                                font.pixelSize: 12
                                font.family: "CaskaydiaCove NF"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: console.log("Bluetooth clicked!")
                            onEntered: parent.color = "#252525"
                            onExited: parent.color = "#1a1a1a"
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        id: contentHover
        target: content
        onHoveredChanged: root.isHovered = hovered
    }
}
