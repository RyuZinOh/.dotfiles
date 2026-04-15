pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
// import qs.Components.Poketwo
// import qs.Modules.Ash
import qs.Components.Artiqa
import qs.Components.Clipsy
import qs.Components.Dancer
import qs.Components.Omnitrix
import qs.Components.Wow
import qs.Components.notification
import qs.Components.osd
import qs.Modules.Hut
import qs.Modules.Toolski
import qs.Modules.TopJesus
import qs.Modules.TopJesus.Callgorl
import qs.utils

Scope {
    Variants {
        model: Quickshell.screens

        Scope {
            id: screenScope

            required property var modelData

            WlrLayershell {
                // Region {
                //     x: (hyperixonLayer.width / 2) - (ashRef.implicitWidth / 2)
                //     y: 10
                //     width: ashRef.implicitWidth
                //     height: ashRef.implicitHeight
                // }

                id: hyperixonLayer

                //jan 1-2026 => at the new year I noticed a shit
                // Component.onCompleted: {
                // console.log("ExclusionMode.Ignore value:", ExclusionMode.Ignore);
                // }
                screen: screenScope.modelData
                layer: WlrLayer.Top // ok Overlay wasnt the deal breaker here, I was thinking ass.
                keyboardFocus: WlrKeyboardFocus.OnDemand
                namespace: "quickshell-hyperixon"
                visible: true
                exclusiveZone: -1 // fuckall exclusive zones
                color: "transparent"

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                //content container
                Item {
                    //UnderDevelopment
                    // Ash {
                    //     id: ashRef
                    //     anchors.horizontalCenter: parent.horizontalCenter
                    //     anchors.top: parent.top
                    // }
                    //clipsy clipboard
                    //poketwo -game
                    // poketwo overlay
                    // Loader {
                    //     id: poketwoRef
                    //     anchors.fill: parent
                    //     active: PoketwoConfig.isActive
                    //     sourceComponent: Poketwo {}

                    id: hyperixonContent

                    anchors.fill: parent

                    //topJesus
                    TopJesus {
                        id: topJesusRef

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        parentScreen: hyperixonLayer.screen
                    }

                    Loader {
                        id: clipsyLoader

                        anchors.fill: parent
                        active: false

                        Connections {
                            function onShowClipsy() {
                                clipsyLoader.active = true;
                            }

                            function onHideClipsy() {
                                clipsyLoader.active = false;
                            }

                            target: ClipsyConfig
                        }

                        sourceComponent: Clipsy {
                        }

                    }

                    //notification [Also we can implement our own layershell overlay for this one but nah...]
                    NotificationWindow {
                        id: notifWindow

                        anchors {
                            right: parent.right
                            top: parent.top
                            rightMargin: 4
                            topMargin: 4
                        }

                    }

                    //toolski
                    Toolski {
                        id: toolskiRef

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    //overview -wow
                    Loader {
                        id: wowRef

                        anchors.centerIn: parent
                        active: WowConfig.isActive

                        sourceComponent: Wow {
                        }

                    }

                    //     Connections {
                    //         target: PoketwoConfig
                    //         function onShowPoketwo() {
                    //             poketwoRef.active = true;
                    //         }
                    //         function onHidePoketwo() {
                    //             poketwoRef.active = false;
                    //         }
                    //     }
                    // }
                    //hut
                    Hut {
                        id: hutRef

                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right
                        }

                    }

                    //omnitrix launcher
                    OmnitrixLauncher {
                        id: omnitrixLauncher

                        anchors.fill: parent
                        active: false

                        Connections {
                            function onShowOmnitrix() {
                                omnitrixLauncher.active = true;
                            }

                            function onHideOmnitrix() {
                                omnitrixLauncher.active = false;
                            }

                            target: OmnitrixConfig
                        }

                    }

                    //bouncing dancer
                    BouncingDancer {
                        id: bouncingDancer

                        anchors.fill: parent
                        active: false

                        Connections {
                            function onShowDancer() {
                                bouncingDancer.active = true;
                            }

                            function onHideDancer() {
                                bouncingDancer.active = false;
                            }

                            target: DancerConfig
                        }

                    }

                    //artiqa drawing utility
                    Artiqa {
                        id: artiqaRef

                        property var pimp

                        anchors.fill: parent
                        active: false
                        focus: active
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) {
                                pimp.call("artiqa", "deactivate");
                                event.accepted = true;
                            }
                        }
                        onActiveChanged: {
                            if (!active && ArtiqaConfig.isActive)
                                pimp.call("artiqa", "deactivate");

                        }

                        Connections {
                            function onShowArtiqa() {
                                artiqaRef.active = true;
                            }

                            function onHideArtiqa() {
                                artiqaRef.active = false;
                            }

                            target: ArtiqaConfig
                        }

                        pimp: Pimp {
                        }

                    }

                    //osd
                    Osd {
                        id: osdWindow

                        anchors {
                            right: parent.right
                            top: parent.top
                            rightMargin: 20
                            topMargin: 20
                        }

                    }

                }

                //enable this for extra pin stuff [very interesthing]
                WlrLayershell {
                    id: pinLayer

                    screen: screenScope.modelData
                    layer: WlrLayer.Top
                    namespace: "quickshell-hyperixon-pin"
                    visible: topJesusRef.isPinned
                    anchors.top: true
                    implicitWidth: 0
                    implicitHeight: 0
                    exclusiveZone: 40
                }

                /* Dynamic mask that changes based on hover state
                 when not hovered: tiny strip at top, when hovered: full panel height
                */
                mask: Region {
                    // Region {
                    //     x: (hyperixonLayer.width / 2) - 720
                    //     y: 0
                    //     width: 1440
                    //     height: topJesusRef.maskHeight
                    // }
                    //
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
                        x: (hyperixonLayer.width / 2) - 300 // 600/2 = 300 (width of omnitrix)
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
                    //Hut

                    Region {
                        x: hyperixonLayer.width - hutRef.maskWidth
                        y: 0
                        width: hutRef.maskWidth
                        height: hyperixonLayer.height

                        //Artiqa
                        Region {
                            x: 0
                            y: 0
                            width: artiqaRef.active ? hyperixonLayer.width : 1
                            height: artiqaRef.active ? hyperixonLayer.height : 1
                        }

                        //wow
                        Region {
                            x: (hyperixonLayer.width / 2) - (wowRef.width / 2)
                            y: (hyperixonLayer.height / 2) - (wowRef.height / 2)
                            width: WowConfig.isActive ? wowRef.width : 1
                            height: WowConfig.isActive ? wowRef.height : 1
                        }

                        //Clipsy
                        Region {
                            x: (hyperixonLayer.width / 2) - 250
                            y: (hyperixonLayer.height / 2) - (ClipsyConfig.panelHeight / 2)
                            width: ClipsyConfig.isActive ? 500 : 1
                            height: ClipsyConfig.isActive ? ClipsyConfig.panelHeight : 1
                        }

                    }

                }

            }

        }

    }

}
