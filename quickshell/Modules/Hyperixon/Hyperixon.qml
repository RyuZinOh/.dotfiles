import qs.Services.Notification
import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Modules.TopJesus

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
                    x: (hyperixonLayer.width / 2) - (topJesusRef.width / 2) //now supporting width cause component lke wow has width factor so..
                    y: 0
                    width: topJesusRef.width
                    height: (topJesusRef.isHovered || topJesusRef.isPinned) ? topJesusRef.height + 20 : 1
                }

                /*
                notification area -> dynamically
                sized based on actual content height
                grows as more cards are added
                */
                Region {
                    x: hyperixonLayer.width - 400
                    y: 0
                    width: 400
                    height: notifWindow.hasNotifications ? notifWindow.height : 1
                }
            }

            //content container
            Item {
                id: hyperixonContent
                anchors.fill: parent

                //topJesus
                TopJesus {
                    id: topJesusRef
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                }

                //notification
                NotificationWindow {
                    id: notifWindow
                    //anchors.topMargin: 20
                    anchors.right: parent.right
                    anchors.top: parent.top
                    property bool hasNotifications: queue.length > 0
                }
            }
        }
    }
}
