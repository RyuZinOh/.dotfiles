// qs/Modules/Hyperixon/Hyperixon.qml
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
                    height: controlRoomRef.isHovered ? 340 : 1   // will work with 0.1 smh later for now
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
            }
        }
    }
}
