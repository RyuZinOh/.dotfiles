import QtQuick
import Quickshell.Io

Item {
    id: root
    anchors.fill: parent
    readonly property string surfaceColor: "#100C08"
    readonly property string primaryColor: "#ffffff"
    Process {
        id: cleanupProcess
        command: ["bash", Qt.resolvedUrl("../../Scripts/refresh.sh").toString().replace("file://", "")]
        onExited: (code, status) => {
            if (code === 0) {
                console.log("Cache cleanup success");
            } else {
                console.error("Cleanup failed", code);
            }
        }
    }
    Rectangle {
        id: contextMenu
        width: 180
        height: 52
        color: surfaceColor
        radius: 8
        visible: false
        z: 1000
        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            color: refreshMouse.containsMouse ? Qt.lighter(surfaceColor, 1.2) : surfaceColor
            radius: 6
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
                Text {
                    id: iconText
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰑐"
                    color: primaryColor
                    font.pixelSize: 16
                    font.family: "CaskaydiaCove NF"
                    // rotation: refreshMouse.containsMouse ? 360 : 0
                    // Behavior on rotation {
                    //     NumberAnimation {
                    //         duration: 500
                    //         easing.type: Easing.InOutQuad
                    //     }
                    // }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Refresh"
                    color: primaryColor
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
