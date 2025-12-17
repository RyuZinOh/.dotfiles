import QtQuick
import Quickshell.Io
import qs.Services.Theme

Item {
    id: root
    anchors.fill: parent

    Process {
        id: cleanupProcess
        command: ["bash", Qt.resolvedUrl("../../Scripts/refresh.sh").toString().replace("file://", "")]
        // onExited: (code, status) => {
        //     if (code === 0) {
        //         console.log("Cache cleanup success");
        //     } else {
        //         console.error("Cleanup failed", code);
        //     }
        // }
    }
    Rectangle {
        id: contextMenu
        width: 140
        height: 110
        color: Theme.surfaceContainer
        radius: 8
        visible: false
        z: 1000

        Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6

            Rectangle {
                width: parent.width
                height: 44
                color: refreshMouse.containsMouse ? Theme.surfaceBright : "transparent"
                radius: 6

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰑐"
                        color: Theme.primaryColor
                        font.pixelSize: 18
                        font.family: "CaskaydiaCove NF"
                        rotation: refreshMouse.containsMouse ? 360 : 0
                        Behavior on rotation {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Refresh"
                        color: Theme.onSurface
                        font.pixelSize: 13
                        font.family: "CaskaydiaCove NF"
                    }
                }
                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contextMenu.visible = false;
                        cleanupProcess.running = true;
                    }
                }
            }

            /* theme toggle*/
            Rectangle {
                width: parent.width
                height: 44
                color: themeMouse.containsMouse ? Theme.surfaceBright : "transparent"
                radius: 6

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Theme.isDarkMode ? "󰖔" : "󰖙"
                        color: Theme.primaryColor
                        font.pixelSize: 18
                        font.family: "CaskaydiaCove NF"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Theme.isDarkMode ? "Light" : "Dark"
                        color: Theme.onSurface
                        font.pixelSize: 14
                        font.family: "CaskaydiaCove NF"
                    }
                }

                MouseArea {
                    id: themeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contextMenu.visible = false;
                        Theme.toggleMode();
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                contextMenu.x = Math.min(mouse.x, root.width - contextMenu.width - 10);
                contextMenu.y = Math.min(mouse.y, root.height - contextMenu.height - 10);
                contextMenu.visible = true;
            } else if (contextMenu.visible) {
                contextMenu.visible = false;
            }
        }
    }
}
