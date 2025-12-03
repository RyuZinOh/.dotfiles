import Quickshell
import QtQuick
import qs.Components.workspace
import qs.Components.ymdt
import qs.Components.battery
// import QtQuick.Effects
import Quickshell.Io
import QtQuick.Controls

Scope {
    property bool dockerRunning: false
    property bool mariadbRunning: false
    property bool nginxRunning: false
    property bool apacheRunning: false

    Process {
        id: dockerCheck
        command: ["systemctl", "is-active", "docker"]
        running: true
        onExited: (code, status) => {
            dockerRunning = (code === 0);
        }
    }

    Process {
        id: mariadbCheck
        command: ["systemctl", "is-active", "mariadb"]
        running: true
        onExited: (code, status) => {
            mariadbRunning = (code === 0);
        }
    }

    Process {
        id: nginxCheck
        command: ["systemctl", "is-active", "nginx"]
        running: true
        onExited: (code, status) => {
            nginxRunning = (code === 0);
        }
    }
    Process {
        id: apacheCheck
        command: ["systemctl", "is-active", "httpd"]
        running: true
        onExited: (code, status) => {
            apacheRunning = (code === 0);
        }
    }
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            dockerCheck.running = true;
            mariadbCheck.running = true;
            nginxCheck.running = true;
            apacheCheck.running  = true;
        }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: mainBar
            required property var modelData
            screen: modelData

            //layouts
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 40

            color: "transparent"

            // MASKING: capturing only UI Elemetns
            // in this case transparents stuffs are passthrough
            // mask: Region {
            //     Region {
            //         item: logo
            //     }
            //     Region {
            //         item: serviceStatus
            //     }
            //     Region {
            //         item: workspaces
            //     }
            //     Region {
            //         item: rightPanelBg
            //     }
            // }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                Rectangle {
                    id: logo
                    width: 35
                    height: 35
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 2

                    Rectangle {
                        id: blackBackground
                        anchors.fill: parent
                        color: "black"
                        Text {
                            text: "\uF303"
                            font.pixelSize: 24
                            color: "blue"
                            anchors.centerIn: parent
                        }
                    }
                    // MultiEffect {
                    //   source: blackBackground
                    //   anchors.fill: blackBackground
                    //     blurEnabled: true
                    //     blurMax: 64
                    //     blur: 1.0
                    // }
                    MouseArea {
                        width: logo.width
                        height: logo.height

                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached("/home/safal726/.config/quickshell/Scripts/powerski");
                        }
                    }
                }

                Rectangle {
                    id: serviceStatus
                    color: "black"
                    height: 35
                    width: serviceRow.width + 16
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: logo.right
                    anchors.leftMargin: 8

                    Row {
                        id: serviceRow
                        spacing: 10
                        anchors.centerIn: parent

                        // Docker indicator
                        Text {
                            id: dockerIcon
                            text: "\uF308"
                            font.pixelSize: 24
                            font.family: "0xProto Nerd Font"
                            color: dockerRunning ? "#00ff00" : "red"
                            anchors.verticalCenter: parent.verticalCenter

                            ToolTip {
                                id: dockerTooltip
                                visible: dockerMouseArea.containsMouse
                                text: dockerRunning ? "Docker is running" : "Docker is not running"
                                delay: 300

                                background: Rectangle {
                                    color: "black"
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: dockerTooltip.text
                                    color: "white"
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                id: dockerMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }

                        // MariaDB indicator
                        Text {
                            id: mariadbIcon
                            text: "\ue828"
                            font.pixelSize: 24
                            font.family: "0xProto Nerd Font"
                            color: mariadbRunning ? "#00ff00" : "red"
                            anchors.verticalCenter: parent.verticalCenter

                            ToolTip {
                                id: mariadbTooltip
                                visible: mariadbMouseArea.containsMouse
                                text: mariadbRunning ? "MariaDB is running" : "MariaDB is not running"
                                delay: 300

                                background: Rectangle {
                                    color: "black"
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: mariadbTooltip.text
                                    color: "white"
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                id: mariadbMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }

                        // Nginx indicator
                        Text {
                            id: nginxIcon
                            text: "\ue776"
                            font.pixelSize: 24
                            font.family: "0xProto Nerd Font"
                            color: nginxRunning ? "#00ff00" : "red"
                            anchors.verticalCenter: parent.verticalCenter

                            ToolTip {
                                id: nginxTooltip
                                visible: nginxMouseArea.containsMouse
                                text: nginxRunning ? "Nginx is running" : "Nginx is not running"
                                delay: 300

                                background: Rectangle {
                                    color: "black"
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: nginxTooltip.text
                                    color: "white"
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                id: nginxMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }

                        //apache-httpd indicator
                        Text {
                            id: apacheIcon
                            text: "\ue72b"
                            font.pixelSize: 24
                            font.family: "0xProto Nerd Font"
                            color: apacheRunning ? "#00ff00" : "red"
                            anchors.verticalCenter: parent.verticalCenter

                            ToolTip {
                                id: apacheTooltip
                                visible: apacheMouseArea.containsMouse
                                text: apacheRunning ? "Apache is running" : "Apache is not running"
                                delay: 300

                                background: Rectangle {
                                    color: "black"
                                    radius: 4
                                }

                                contentItem: Text {
                                    text: apacheTooltip.text
                                    color: "white"
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                id: apacheMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }
                }

                Workspace {
                    id: workspaces
                    bgOva: "black"
                    height: 35
                    anchors.centerIn: parent
                    workspaceSize: 30
                    spacing: 8
                    showNumbers: true
                }

                Rectangle {
                    id: rightPanelBg
                    color: "black"
                    height: workspaces.height
                    width: rightPanel.width + 20
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    Row {
                        id: rightPanel
                        spacing: 15
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Battery {
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        DayWidget {
                            font.family: "0xProto Nerd Font"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Column {
                            ClockWidget {
                                font.family: "CaskaydiaCove NF"
                                color: "white"
                            }
                            DateWidget {
                                font.family: "CaskaydiaCove NF"
                                color: "white"
                            }
                        }
                    }
                }
            }
        }
    }
}
