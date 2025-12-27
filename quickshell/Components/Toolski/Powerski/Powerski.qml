import QtQuick
import Quickshell.Io
import qs.Services.Theme
import qs.Components.Icon

Item {
    id: root

    Row {
        anchors.centerIn: parent
        spacing: 80

        Column {
            spacing: 10
            Rectangle {
                width: 120
                height: 120
                color: "transparent"

                Icon {
                    name: "power"
                    size: 100
                    color: Theme.onSurface
                    anchors.centerIn: parent
                    scale: shutdownMouse.pressed ? 0.9 : (shutdownMouse.containsMouse ? 1.05 : 1.0)
                    opacity: shutdownMouse.pressed ? 0.5 : 1.0

                    Behavior on scale {
                        SpringAnimation {
                            spring: 3.0
                            damping: 0.4
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }

                MouseArea {
                    id: shutdownMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        shutdownProcess.running = true;
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Shutdown"
                color: Theme.onSurface
                font.pixelSize: 16
                font.weight: Font.Medium
                opacity: shutdownMouse.containsMouse ? 1.0 : 0.7

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }

        Column {
            spacing: 10

            Rectangle {
                width: 120
                height: 120
                color: "transparent"
                Icon {
                    name: "arrow-clockwise"
                    size: 100
                    color: Theme.onSurface
                    anchors.centerIn: parent
                    scale: restartMouse.pressed ? 0.9 : (restartMouse.containsMouse ? 1.05 : 1.0)
                    opacity: restartMouse.pressed ? 0.5 : 1.0

                    Behavior on scale {
                        SpringAnimation {
                            spring: 3.0
                            damping: 0.4
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }

                MouseArea {
                    id: restartMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        restartProcess.running = true;
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Restart"
                color: Theme.onSurface
                font.pixelSize: 16
                font.weight: Font.Medium
                opacity: restartMouse.containsMouse ? 1.0 : 0.7
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
}
