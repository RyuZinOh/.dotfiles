import Quickshell
import QtQuick
import Quickshell.Hyprland
import qs.Components.workspace
import qs.Components.ymdt
import qs.Components.battery

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: mainBar
            required property var modelData
            screen: modelData

            visible: {
                true;
            }

            //layouts
            readonly property int barWidth: Math.min(1440, modelData.width - 40)
            readonly property int centerOffset: (modelData.width - barWidth) / 2
            anchors {
                top: true
                left: true
                right: true
            }
            implicitWidth: barWidth
            implicitHeight: 40

            color: "transparent"
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                Rectangle {
                    id: logo
                    width: 35
                    height: 35
                    color: "black"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 2
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
                            Quickshell.execDetached("/home/safal726/.config/quickshell/Scripts/powerski");
                        }
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
