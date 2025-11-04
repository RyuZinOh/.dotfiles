import Quickshell
import QtQuick

Scope {

    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }

            color: "transparent"
            implicitHeight: 40
            Rectangle {
                id: topBar
                implicitWidth: QsWindow.window?.width ?? 0
                implicitHeight: 40
                color: "transparent"
                anchors.top: parent.top
                Rectangle {
                    width: 35
                    height: 35
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    color: "black"
                    Text {
                        text: "\uF303"
                        font.pixelSize: 24
                        color: "blue"
                        anchors.centerIn: parent
                    }
                }
                Workspace {
                    id: wsps
                    implicitHeight: 35
                    anchors.centerIn: parent
                    workspaceSize: 30
                    spacing: 8
                    // activeColor: "black" [add or it will use the default property]
                    // inactiveColor: "white"
                    showNumbers: true
                }

                Rectangle {
                    id: rightBg
                    color: "black"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 3
                    implicitHeight: wsps.implicitHeight
                    implicitWidth: contentRow.implicitWidth + 20
                    opacity: 0.85
                    Row {
                        id: contentRow
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 20

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
                            //gettng clock ClockWidget
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
