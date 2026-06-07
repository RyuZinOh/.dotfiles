pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components.Poketwo
import qs.Components.Artiqa
import qs.Components.osd
import qs.Components.Dancer
import qs.Components.Omnitrix
import qs.Modules.Hut
import qs.Modules.Toolski
import qs.Modules.TopJesus
import qs.utils

Scope {
    Variants {
        model: Quickshell.screens

        Scope {
            id: screenScope

            required property var modelData

            WlrLayershell {
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
                    //poketwo -game
                    // poketwo overlay — fixed: Component wrapper, redundant Connections removed,
                    // active binding on isActive handles load/unload cleanly
                    Loader {
                        id: poketwoLoader
                        anchors.fill: parent
                        active: PoketwoConfig.isActive
                        sourceComponent: Component {
                            Poketwo {}
                        }
                    }

                    anchors.fill: parent

                    //topJesus
                    TopJesus {
                        id: topJesusRef

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        parentScreen: hyperixonLayer.screen
                    }

                    //clipsy clipboard
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

                        source: "../Components/Clipsy/Clipsy.qml"
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
                        active: DancerConfig.isActive
                    }

                    //artiqa drawing utility
                    Artiqa {
                        id: artiqaRef

                        anchors.fill: parent
                        active: false
                        focus: active
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                ArtiqaConfig.isActive = false;
                                StateManager.set("artiqa", false);
                                ArtiqaConfig.hideArtiqa();
                                event.accepted = true;
                            }
                        }
                        onActiveChanged: {
                            if (!active && ArtiqaConfig.isActive) {
                                ArtiqaConfig.isActive = false;
                                StateManager.set("artiqa", false);
                                ArtiqaConfig.hideArtiqa();
                            }
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
                    }
                    //osd
                    Loader {
                        id: osdWindow

                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 20
                        anchors.topMargin: 20
                        active: OsdConfig.isVisible
                        sourceComponent: Component {
                            Osd {}
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
                    Region {
                        x: (hyperixonLayer.width / 2) - (topJesusRef.width / 2) //now supporting width cause component lke wow has width factor so..
                        y: 0
                        width: topJesusRef.width
                        // height: (topJesusRef.isHovered || topJesusRef.isPinned) ? topJesusRef.height : 1
                        height: (topJesusRef.isHovered || topJesusRef.isPinned) ? topJesusRef.interactiveHeight : 1
                    }
                    /*
                     * omnitrix
                   */
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
                    }
                    //Artiqa

                    Region {
                        x: 0
                        y: 0
                        width: artiqaRef.active ? hyperixonLayer.width : 1
                        height: artiqaRef.active ? hyperixonLayer.height : 1
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
