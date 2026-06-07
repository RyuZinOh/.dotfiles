pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.utils
import qs.Components.Wow
import qs.Modules.Screenshot
import qs.Configuration.Screenshot
import qs.Components.notification
import qs.Services

Scope {
    Variants {
        model: Quickshell.screens
        Scope {
            id: screenScope
            required property var modelData
            property bool isPrimary: screenScope.modelData === Quickshell.screens[0]
            property int activeNotifs: 0
            Loader {
                active: WowConfig.isActive || screenScope.activeNotifs > 0 || ScreenshotConfig.isActive || NotificationService.count > 0

                sourceComponent: Component {
                    WlrLayershell {
                        id: oLay
                        screen: screenScope.modelData
                        layer: WlrLayer.Overlay
                        keyboardFocus: ScreenshotConfig.isSelectingRegion ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
                        namespace: "quickshell-oppression-layer"
                        exclusiveZone: -1
                        // color: WowConfig.isActive ? Qt.rgba(0, 0, 0, 0.1) : "transparent" // for the thang [with hyprland layer rules] only works when blur is enabled in hyprland

                        color: "transparent"
                        anchors {
                            top: true
                            bottom: true
                            left: true
                            right: true
                        }
                        mask: Region {
                            Region {
                                width: (WowConfig.isActive || ScreenshotConfig.isActive) ? oLay.width : 0
                                height: (WowConfig.isActive || ScreenshotConfig.isActive) ? oLay.height : 0
                            }
                            Region {
                                x: notifWindow.x
                                y: notifWindow.y
                                width: notifWindow.visible ? notifWindow.width + 4 : 1
                                height: notifWindow.visible ? notifWindow.height + 4 : 1
                            }
                        }
                        Loader {
                            anchors.fill: parent
                            active: WowConfig.isActive
                            sourceComponent: Component {
                                Wow {}
                            }
                        }
                        Loader {
                            anchors.fill: parent
                            active: ScreenshotConfig.isActive && screenScope.isPrimary
                            sourceComponent: Component {
                                Screenshot {
                                    screen: screenScope.modelData
                                }
                            }
                        }
                        NotificationWindow {
                            id: notifWindow
                            anchors {
                                right: parent.right
                                top: parent.top
                                rightMargin: 4
                                topMargin: 4
                            }
                        }
                    }
                }
            }
        }
    }
}
