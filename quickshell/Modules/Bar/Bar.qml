import Quickshell
import QtQuick
import Quickshell.Hyprland
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

            visible: {
                // const ws = Hyprland.focusedWorkspace;
                // if (!ws) {
                //     return false; // for toplevels of null for kinda safety?
                // }
                // const cnt = ws.toplevels.values.filter(t => !t.lastIpcObject.floating).length;
                // return cnt === 0;
                true;
            }

            //layouts
            readonly property int barWidth: Math.min(1440, modelData.width - 40)
            readonly property int centerOffset: (modelData.width - barWidth) / 2
            anchors {
                top: true
                // left: true
                // right: true
            }
            implicitWidth: barWidth
            implicitHeight: 40

            color: "transparent"
            // Canvas {
            //     id: barshape
            //     anchors.fill: parent
            //
            //     onPaint: {
            //         var ctx = getContext("2d");
            //         ctx.clearRect(0, 0, width, height);
            //
            //         var taperwidth = 10; //taper at edges
            //         var rad = 10;
            //
            //         ctx.fillStyle = "black";
            //         ctx.beginPath();
            //
            //         //top-left
            //         ctx.moveTo(0, 0);
            //
            //         //top-edge
            //         ctx.lineTo(width, 0);
            //
            //         //right edge
            //         ctx.lineTo(width - taperwidth, height - rad);
            //         ctx.quadraticCurveTo(width - taperwidth, height, width - taperwidth - rad, height);
            //
            //         //bottom edge
            //         ctx.lineTo(taperwidth + rad, height);
            //         ctx.quadraticCurveTo(taperwidth, height, taperwidth, height - rad);
            //         //left edge
            //         ctx.lineTo(0, 0);
            //
            //         ctx.closePath();
            //         ctx.fill();
            //     }
            // }

            Canvas {
                id: barshape
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var taperWidth = width * 0.01;
                    var cornerRadius = Math.min(height * 0.15, taperWidth * 0.8);

                    ctx.fillStyle = "black";
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(width, 0);
                    ctx.lineTo(width - taperWidth, height - cornerRadius);
                    ctx.arc(width - taperWidth - cornerRadius, height - cornerRadius, cornerRadius, 0, Math.PI / 2, false);
                    ctx.lineTo(taperWidth + cornerRadius, height);
                    ctx.arc(taperWidth + cornerRadius, height - cornerRadius, cornerRadius, Math.PI / 2, Math.PI, false);
                    ctx.lineTo(0, 0);
                    ctx.closePath();
                    ctx.fill();
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                Rectangle {
                    id: logo
                    width: 35
                    height: 35
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
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
                    id: ptr

                    // anchors.left: logo.right
                    // anchors.right: workspaces.left
                    anchors.top: parent.top
                    anchors.left: parent.left
                    // anchors.bottom: parent.bottom
                    anchors.leftMargin: 250
                    width: 250
                    height: 40
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
                        anchors.rightMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        // C.Wallski {
                        //     anchors.verticalCenter: parent.verticalCenter
                        // }
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
