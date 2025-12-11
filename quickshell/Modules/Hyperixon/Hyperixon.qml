import qs.Services.Notification
import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Modules.ControlRoom

Scope {
    Variants {
        model: Quickshell.screens

        WlrLayershell {
            id: hyperixonLayer
            required property var modelData

            screen: modelData
            layer: WlrLayer.Overlay
            keyboardFocus: WlrKeyboardFocus.OnDemand
            namespace: "quickshell-hyperixon"
            visible: true

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: -1  // fuckall exclusive zones
            color: "transparent"

            /* Dynamic mask that changes based on hover state
             when not hovered: tiny strip at top, when hovered: full panel height
            */
            mask: Region {
                Region {
                    x: (hyperixonLayer.width / 2) - 200
                    y: 0
                    width: 400
                    height: controlRoomRef.isHovered ? controlRoomRef.actualHeight + 20 : 1
                }

                /*
                notification area -> full height when notifications exist, minimal when empty
                [I should be making
                it card based dynamic tbh!, but animation becomes funky...]
                */
                Region {
                    x: hyperixonLayer.width - 400
                    y: 0
                    width: 400
                    height: notifWindow.hasNotifications ? 650 : 1
                }
            }

            //content container
            Item {
                id: hyperixonContent
                anchors.fill: parent

                Rectangle {
                    id: topTrigger
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: 400
                    height: 1
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: controlRoomRef.isHovered = true
                    }
                }

                //controlroom
                ControlRoom {
                    id: controlRoomRef
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                }

                //notification
                NotificationWindow {
                    id: notifWindow
                    anchors.topMargin: 20
                    anchors.right: parent.right
                    anchors.top: parent.top
                    property bool hasNotifications: queue.length > 0
                }
            }
        }
    }
}
