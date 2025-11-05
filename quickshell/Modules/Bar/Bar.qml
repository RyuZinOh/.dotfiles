import Quickshell
import QtQuick
import qs.components
import qs.Modules.Bar.ymdt
import qs.Modules.Bar.workspace
import qs.Modules.Bar.battery
import Qt5Compat.GraphicalEffects

Scope {
    QtObject {
        id: popupState
        property bool mouseInside: false
        property int targetHeight: 200
        property int animationDuration: 200
    }

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
            implicitHeight: 40

            Rectangle {
                id: topBar
                implicitWidth: QsWindow.window?.width ?? 0
                implicitHeight: 40
                anchors.top: parent.top

                Rectangle {
                    id: archLogo
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

                MouseArea {
                    id: triggerArea
                    anchors.left: archLogo.right
                    anchors.right: wsps.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    hoverEnabled: true
                    onEntered: {
                        popupState.mouseInside = true;
                        hideTimer.stop();
                        if (!popupWindow.visible) {
                            popupWindow.visible = true;
                        }
                        popupPanel.height = popupState.targetHeight;
                    }
                    onExited: {
                        popupState.mouseInside = false;
                        hideTimer.start();
                    }
                }

                Workspace {
                    id: wsps
                    implicitHeight: 35
                    anchors.centerIn: parent
                    workspaceSize: 30
                    spacing: 8
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

    PanelWindow {
        id: popupWindow
        visible: false
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: 250
        implicitHeight: 200
        anchors.top: true
        anchors.left: true
        margins.top: 40
        margins.left: 120

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            clip: true

            PopoutShape {
                id: popupPanel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 0
                radius: 15
                color: "white"
                style: 1
                alignment: 0
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: popupState.animationDuration
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.34, 1.56, 0.64, 1]
                    }
                }

                // // Opacity animation for smooth appearance
                // opacity: height / popupState.targetHeight
                //
                // Behavior on opacity {
                //     NumberAnimation {
                //         duration: popupState.animationDuration * 0.8
                //         easing.type: Easing.OutCubic
                //     }
                // }

                Column {
                    anchors.centerIn: parent
                    spacing: 8  

                    Rectangle {
                        width: 100
                        height: 100
                        color: "white"
                        border.width: 0
                        radius: 10
                        layer.enabled: true
                        layer.effect: DropShadow {
                            transparentBorder: true
                            horizontalOffset: 2
                            verticalOffset: 2
                            radius: 6
                            color: "purple"
                        }

                        Image {
                            id: icon1
                            source: "/home/safal726/pfps/nura.jpg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: -10
                            width: parent.width
                            height: parent.height
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Text {
                        text: "safalSki"
                        font.family: "Poppins"
                        font.bold: true
                        font.pointSize: 18   // reduced from 36 to fit nicely below the image
                        color: "black"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            MouseArea {
                id: popupHoverArea
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onEntered: {
                    popupState.mouseInside = true;
                    hideTimer.stop();
                }
                onExited: {
                    popupState.mouseInside = false;
                    hideTimer.start();
                }
                onPressed: mouse.accepted = false
                onReleased: mouse.accepted = false
                onClicked: mouse.accepted = false
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 200
        onTriggered: {
            if (!popupState.mouseInside) {
                popupPanel.height = 0;
                Qt.callLater(function () {
                    if (popupPanel.height === 0) {
                        popupWindow.visible = false;
                    }
                });
            }
        }
    }
}
