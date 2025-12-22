import qs.Services.Notification
import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Modules.TopJesus
import qs.Data
import qs.Components.Dancer
import qs.Components.Omnitrix

// import qs.Components.Toolski

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

                Region {
                    x: (hyperixonLayer.width / 2) - 300  // 600/2 = 300 (width of omnitrix)
                    y: (hyperixonLayer.height / 2) - 300 // 600/2 = 300 (height of omnitrix)
                    width: omnitrixLauncher.active ? 600 : 1
                    height: omnitrixLauncher.active ? 600 : 1
                }

                /*Toolski
                  - balls
                  - blades
                  - card
                 */
                // Region {
                //     x: 0
                //     y: (hyperixonLayer.height / 2) - 30
                //     width: 60
                //     height: 60
                // }
                //
                // Region {
                //     x: toolskiRef.isExpanded ? 65 : 0
                //     y: (hyperixonLayer.height / 2) - 100
                //     width: toolskiRef.isExpanded ? 200 : 1
                //     height: toolskiRef.isExpanded ? 200 : 1
                // }
                // Region {
                //     x: toolskiRef.openedBladeIndex !== -1 ? (hyperixonLayer.width / 2) - 250 : 0
                //     y: toolskiRef.openedBladeIndex !== -1 ? (hyperixonLayer.height / 2) - 350 : 0
                //     width: toolskiRef.openedBladeIndex !== -1 ? 500 : 1
                //     height: toolskiRef.openedBladeIndex !== -1 ? 700 : 1
                // }
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

                //toolski [If U want the ball then go for it.../ I don't want ball until its fully ready]
                // Toolski {
                //     id: toolskiRef
                //     anchors.left: parent.left
                //     anchors.verticalCenter: parent.verticalCenter
                // }

                //omnitrix launcher
                OmnitrixLauncher {
                    id: omnitrixLauncher
                    anchors.fill: parent
                    active: false

                    Connections {
                        target: OmnitrixConfig

                        function onShowOmnitrix() {
                            omnitrixLauncher.active = true;
                        }

                        function onHideOmnitrix() {
                            omnitrixLauncher.active = false;
                        }
                    }
                }
                //bouncing dancer
                BouncingDancer {
                    id: bouncingDancer
                    anchors.fill: parent
                    active: false

                    Connections {
                        target: DancerConfig

                        function onShowDancer() {
                            bouncingDancer.active = true;
                        }

                        function onHideDancer() {
                            bouncingDancer.active = false;
                        }
                    }
                }
            }
        }
    }
}
