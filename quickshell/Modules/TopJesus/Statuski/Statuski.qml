import QtQuick
import QtQuick.Controls
import Quickshell.Io
// import QtQuick.Effects
import qs.Components.workspace
import qs.Components.ymdt
import qs.Components.battery
import qs.Services.Theme

// import qs.Components.bongo [enable if you want]

Item {
    id: root
    implicitWidth: 1440
    implicitHeight: 80

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
            apacheCheck.running = true;
        }
    }

    Rectangle {
        id: logo
        width: 50
        height: 50
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        color: "transparent"

        Text {
            text: "\uF303"
            font.pixelSize: 32
            color: Theme.primaryColor
            anchors.centerIn: parent
        }

        // MultiEffect {
        //   source: blackBackground
        //   anchors.fill: blackBackground
        //     blurEnabled: true
        //     blurMax: 64
        //     blur: 1.0
        // }
    }

    Rectangle {
        id: serviceStatus
        color: "transparent"
        height: 50
        width: serviceRow.width + 24
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: logo.right
        anchors.leftMargin: 12

        Row {
            id: serviceRow
            spacing: 15
            anchors.centerIn: parent

            // Docker indicator
            Text {
                id: dockerIcon
                text: "\uF308"
                font.pixelSize: 32
                font.family: "0xProto Nerd Font"
                color: dockerRunning ? Theme.primaryColor : Theme.errorColor
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                ToolTip {
                    id: dockerTooltip
                    visible: dockerMouseArea.containsMouse
                    text: dockerRunning ? "Docker is running" : "Docker is not running"
                    delay: 300

                    background: Rectangle {
                        color: Theme.surfaceContainer
                        radius: 4
                        implicitWidth: 140
                        implicitHeight: 70
                    }

                    contentItem: Text {
                        text: dockerTooltip.text
                        color: Theme.onSurface
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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
                font.pixelSize: 32
                font.family: "0xProto Nerd Font"
                color: mariadbRunning ? Theme.primaryColor : Theme.errorColor
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                ToolTip {
                    id: mariadbTooltip
                    visible: mariadbMouseArea.containsMouse
                    text: mariadbRunning ? "MariaDB is running" : "MariaDB is not running"
                    delay: 300

                    background: Rectangle {
                        color: Theme.surfaceContainer
                        radius: 4
                        implicitWidth: 140
                        implicitHeight: 70
                    }

                    contentItem: Text {
                        text: mariadbTooltip.text
                        color: Theme.onSurface
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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
                font.pixelSize: 32
                font.family: "0xProto Nerd Font"
                color: nginxRunning ? Theme.primaryColor : Theme.errorColor
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                ToolTip {
                    id: nginxTooltip
                    visible: nginxMouseArea.containsMouse
                    text: nginxRunning ? "Nginx is running" : "Nginx is not running"
                    delay: 300

                    background: Rectangle {
                        color: Theme.surfaceContainer
                        radius: 4
                        implicitWidth: 140
                        implicitHeight: 70
                    }

                    contentItem: Text {
                        text: nginxTooltip.text
                        color: Theme.onSurface
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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
                font.pixelSize: 32
                font.family: "0xProto Nerd Font"
                color: apacheRunning ? Theme.primaryColor : Theme.errorColor
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                ToolTip {
                    id: apacheTooltip
                    visible: apacheMouseArea.containsMouse
                    text: apacheRunning ? "Apache is running" : "Apache is not running"
                    delay: 300

                    background: Rectangle {
                        color: Theme.surfaceContainer
                        radius: 4
                        implicitWidth: 140
                        implicitHeight: 70
                    }

                    contentItem: Text {
                        text: apacheTooltip.text
                        color: Theme.onSurface
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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

    // BONGO neko [uncomment if you want to use, I don't see anytPoint using it beside showcasing]
    // Rectangle {
    //     id: bongoCatContainer
    //     color: Theme.surfaceContainer
    //     height: 50
    //     width: 45
    //     anchors.verticalCenter: parent.verticalCenter
    //     anchors.left: serviceStatus.right
    //     anchors.leftMargin: 12
    //     BongoCat {
    //         anchors.centerIn: parent
    //         size: 45
    //     }
    // }

    Workspace {
        id: workspaces
        bgOva: "transparent"
        height: 50
        anchors.centerIn: parent
        workspaceSize: 40
        spacing: 12
        showNumbers: true
    }

    Rectangle {
        id: rightPanelBg
        color: "transparent"
        height: 50
        width: rightPanel.width + 30
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 5

        Row {
            id: rightPanel
            spacing: 20
            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter

            Battery {
                anchors.verticalCenter: parent.verticalCenter
            }

            DayWidget {
                font.family: "0xProto Nerd Font"
                font.pixelSize: 20
                font.bold: true
                color: Theme.onSurface
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                spacing: 2

                ClockWidget {
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 18
                    color: Theme.onSurface
                }

                DateWidget {
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 18
                    color: Theme.onSurface
                }
            }
        }
    }
}
