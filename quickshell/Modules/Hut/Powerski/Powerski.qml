import QtQuick
import Quickshell.Io
import qs.Services.Theme
import qs.Components.Icon

Item {
    id: root

    implicitWidth: row.width
    implicitHeight: row.height

    Row {
        id: row
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 24

        Column {
            spacing: 4

            Rectangle {
                width: 64
                height: 64
                radius: shutdownMouse.containsMouse ? 32 : 16
                color: shutdownMouse.containsMouse ? Theme.primaryContainer : Theme.surfaceContainerHighest
                border.width: shutdownMouse.containsMouse ? 2 : 1
                border.color: shutdownMouse.containsMouse ? Theme.primaryColor : Theme.outlineVariant
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

                Icon {
                    name: "power"
                    size: 28
                    color: shutdownMouse.containsMouse ? Theme.onPrimaryContainer : Theme.onSurface
                    anchors.centerIn: parent
                    scale: shutdownMouse.pressed ? 0.9 : 1.0

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
                    id: shutdownMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shutdownProcess.running = true
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Shutdown"
                color: Theme.onSurface
                font.pixelSize: 11
                font.family: "CaskaydiaCove NF"
                font.weight: Font.Medium
                opacity: shutdownMouse.containsMouse ? 1.0 : 0.0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }

        Column {
            spacing: 4

            Rectangle {
                width: 64
                height: 64
                radius: restartMouse.containsMouse ? 32 : 16
                color: restartMouse.containsMouse ? Theme.secondaryContainer : Theme.surfaceContainerHighest
                border.width: restartMouse.containsMouse ? 2 : 1
                border.color: restartMouse.containsMouse ? Theme.secondaryColor : Theme.outlineVariant
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

                Icon {
                    name: "arrow-clockwise"
                    size: 28
                    color: restartMouse.containsMouse ? Theme.onSecondaryContainer : Theme.onSurface
                    anchors.centerIn: parent
                    scale: restartMouse.pressed ? 0.9 : 1.0

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
                    id: restartMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: restartProcess.running = true
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Restart"
                color: Theme.onSurface
                font.pixelSize: 11
                font.family: "CaskaydiaCove NF"
                font.weight: Font.Medium
                opacity: restartMouse.containsMouse ? 1.0 : 0.0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }

        Column {
            spacing: 4

            Rectangle {
                width: 64
                height: 64
                radius: lockMouse.containsMouse ? 32 : 16
                color: lockMouse.containsMouse ? Theme.tertiaryContainer : Theme.surfaceContainerHighest
                border.width: lockMouse.containsMouse ? 2 : 1
                border.color: lockMouse.containsMouse ? Theme.tertiaryColor : Theme.outlineVariant
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

                Icon {
                    name: "lock"
                    size: 28
                    color: lockMouse.containsMouse ? Theme.onTertiaryContainer : Theme.onSurface
                    anchors.centerIn: parent
                    scale: lockMouse.pressed ? 0.9 : 1.0

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
                    id: lockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: lockProcess.running = true
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Lock"
                color: Theme.onSurface
                font.pixelSize: 11
                font.family: "CaskaydiaCove NF"
                font.weight: Font.Medium
                opacity: lockMouse.containsMouse ? 1.0 : 0.0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }
    }

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
        running: false
    }

    Process {
        id: restartProcess
        command: ["systemctl", "reboot"]
        running: false
    }

    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
        running: false
    }
}
