import qs.Components.notification
import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Components.Dancer
import qs.Components.Omnitrix
// import qs.Modules.Ash
import qs.Components.Artiqa
import qs.Modules.Hut
import qs.Modules.Toolski
import qs.Modules.TopJesus
import qs.Modules.TopJesus.Callgorl
import qs.utils

Scope {
    Variants {
        model: Quickshell.screens

        WlrLayershell {
            id: hyperixonLayer
            required property var modelData

            /*jan 1-2026 => at the new year I noticed a shit*/
            Component.onCompleted: {
                console.log("ExclusionMode.Ignore value:", ExclusionMode.Ignore);
            }
            screen: modelData
            layer: WlrLayer.Top // ok Overlay wasnt the deal breaker here, I was thinking ass.
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
                    height: (topJesusRef.isHovered || topJesusRef.isPinned) ? topJesusRef.height : 1
                }

                /*
                notification area -> dynamically
                sized based on actual content height
                grows as more cards are added
                */
                Region {
                    x: hyperixonLayer.width - 440
                    y: 0
                    width: 440
                    height: notifWindow.visible ? notifWindow.height : 1
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
                Region {
                    x: 0
                    y: (hyperixonLayer.height / 2) - 50
                    width: toolskiRef.isHovered ? 0 : 10
                    height: 100
                }
                Region {
                    x: 0
                    y: (hyperixonLayer.height / 2) - 30
                    width: toolskiRef.isHovered ? 60 : 1
                    height: toolskiRef.isHovered ? 60 : 1
                }
                Region {
                    x: toolskiRef.isExpanded ? 65 : 0
                    y: (hyperixonLayer.height / 2) - 100
                    width: toolskiRef.isExpanded ? 200 : 1
                    height: toolskiRef.isExpanded ? 200 : 1
                }
                Region {
                    x: toolskiRef.openedBladeIndex !== -1 ? (hyperixonLayer.width / 2) - (toolskiRef.currentCardWidth / 2) : 0
                    y: toolskiRef.openedBladeIndex !== -1 ? (hyperixonLayer.height / 2) - (toolskiRef.currentCardHeight / 2) : 0
                    width: toolskiRef.openedBladeIndex !== -1 ? toolskiRef.currentCardWidth : 1
                    height: toolskiRef.openedBladeIndex !== -1 ? toolskiRef.currentCardHeight : 1
                }
                /*Hut*/
                Region {
                    x: hyperixonLayer.width - hutRef.width
                    y: 0
                    width: hutRef.isHovered ? hutRef.width : 1
                    height: hutRef.isHovered ? hutRef.height : 1
                }
                /*Project Ash*/
                // Region {
                //     x: (hyperixonLayer.width / 2) - (ashRef.implicitWidth / 2)
                //     y: 10
                //     width: ashRef.implicitWidth
                //     height: ashRef.implicitHeight
                // }

                /*Artiqa*/
                Region {
                    x: 0
                    y: 0
                    width: artiqaRef.active ? hyperixonLayer.width : 1
                    height: artiqaRef.active ? hyperixonLayer.height : 1
                }
            }

            //content container
            Item {
                id: hyperixonContent
                anchors.fill: parent

                /*UnderDevelopment*/
                // Ash {
                //     id: ashRef
                //     anchors.horizontalCenter: parent.horizontalCenter
                //     anchors.top: parent.top
                // }

                //topJesus
                TopJesus {
                    id: topJesusRef
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    parentScreen: hyperixonLayer.screen
                }

                //notification [Also we can implement our own layershell overlay for this one but nah...]
                NotificationWindow {
                    id: notifWindow
                    anchors {
                        right: parent.right
                        topMargin: 50
                    }
                }
                //toolski
                Toolski {
                    id: toolskiRef
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                //hut
                Hut {
                    id: hutRef
                    anchors.top: parent.top
                    anchors.right: parent.right
                }
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
                //artiqa drawing utility
                Artiqa {
                    id: artiqaRef
                    anchors.fill: parent
                    active: false

                    focus: active
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            pimp.call("artiqa", "deactivate");
                            event.accepted = true;
                        }
                    }

                    property var pimp: Pimp {}

                    onActiveChanged: {
                        if (!active && ArtiqaConfig.isActive) {
                            pimp.call("artiqa", "deactivate");
                        }
                    }

                    Connections {
                        target: ArtiqaConfig

                        function onShowArtiqa() {
                            artiqaRef.active = true;
                        }

                        function onHideArtiqa() {
                            artiqaRef.active = false;
                        }
                    }
                }
            }
        }
    }
}
