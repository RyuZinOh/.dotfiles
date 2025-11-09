import Quickshell
import QtQuick
import qs.Modules.Bar as C
import qs.Modules.Bar.workspace
import qs.Modules.Bar.battery
import qs.Modules.Bar.ymdt

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: mainBar
            required property var modelData
            screen: modelData

            //layouts
            readonly property int barWidth: Math.min(1440, modelData.width - 40)
            readonly property int centerOffset: (modelData.width - barWidth) / 2
            anchors.top: true
            implicitWidth: barWidth
            implicitHeight: 40

            color: "transparent"
            Rectangle {
                anchors.fill: parent
                color: "black"
                Rectangle {
                    id: logo
                    width: 35
                    height: 35
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    Text {
                        text: "\uF303"
                        font.pixelSize: 24
                        color: "blue"
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        width: logo.width
                        height: logo.height

                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached("/home/safal726/Development/powerski/build/powerski");
                        }
                    }
                }

                // toggling and starting the hiding timer after invoking this
                MouseArea {
                    anchors.left: logo.right
                    anchors.right: workspaces.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    hoverEnabled: true
                    onEntered: ppWindow.toggle(true)
                    onExited: {
                        ppWindow.hovered = false;
                        ppWindow.hideT.restart();
                    }
                }
                Workspace {
                    id: workspaces
                    height: 35
                    anchors.centerIn: parent
                    workspaceSize: 30
                    spacing: 8
                    showNumbers: true
                }
                Rectangle {
                    color: "transparent"
                    height: workspaces.height
                    width: rightPanel.width + 20
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 3

                    Row {
                        id: rightPanel
                        spacing: 20
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        Battery {
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        DayWidget {

                            font.family: "0xProto Nerd Font"
                            font.pixelSize: 20
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
    //importing the popski component
    C.Popski {
        id: ppWindow
    }
    C.BatteryPopup {
        id: batteryPopup
    }
    C.NotificationPop {
        id: notificationPopup
    }
}
