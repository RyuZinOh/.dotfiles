import QtQuick
import Quickshell
import qs.Services.Theme

Item {
    id: root

    Rectangle {
        anchors.centerIn: parent
        width: row.width + 48
        height: row.height + 32
        color: "transparent"
        border.width: 1
        border.color: Theme.outlineVariant
        radius: 12
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 24

        Repeater {
            model: [
                {
                    icon: "󰐥",
                    label: "Shutdown",
                    activeColor: Theme.primaryContainer,
                    activeBorder: Theme.primaryColor,
                    activeText: Theme.onPrimaryContainer,
                    cmd: ["systemctl", "poweroff"]
                },
                {
                    icon: "󰜉",
                    label: "Restart",
                    activeColor: Theme.secondaryContainer,
                    activeBorder: Theme.secondaryColor,
                    activeText: Theme.onSecondaryContainer,
                    cmd: ["systemctl", "reboot"]
                },
                {
                    icon: "󰌾",
                    label: "Lock",
                    activeColor: Theme.tertiaryContainer,
                    activeBorder: Theme.tertiaryColor,
                    activeText: Theme.onTertiaryContainer,
                    cmd: ["loginctl", "lock-session"]
                },
            ]

            delegate: Column {
                id: btn
                required property var modelData
                spacing: 4

                Rectangle {
                    width: 64
                    height: 64
                    radius: btnMouse.containsMouse ? 32 : 16
                    color: btnMouse.containsMouse ? btn.modelData.activeColor : Theme.surfaceContainerLow
                    border.width: 1
                    border.color: btnMouse.containsMouse ? btn.modelData.activeBorder : Theme.outlineVariant
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on radius {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on border.width {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    Text {
                        text: btn.modelData.icon
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 28
                        color: btnMouse.containsMouse ? btn.modelData.activeText : Theme.onSurface
                        anchors.centerIn: parent
                        scale: btnMouse.pressed ? 0.9 : 1.0

                        Behavior on scale {
                            SpringAnimation {
                                spring: 3.0
                                damping: 0.5
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: btnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("") || Quickshell.execDetached(btn.modelData.cmd)
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: btn.modelData.label
                    color: Theme.onSurface
                    font.pixelSize: 11
                    font.family: "CaskaydiaCove NF"
                    font.weight: Font.Medium
                    opacity: btnMouse.containsMouse ? 1.0 : 0.7
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }
    }
}
