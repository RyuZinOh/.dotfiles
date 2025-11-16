import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Modules.Wallski
import qs.Services.Notification
import qs.Data as Dat

Scope {
    // background layer [wallpaper]
    Variants {
        model: Quickshell.screens
        WlrLayershell {
            id: homeLayer
            required property var modelData
            screen: modelData
            layer: WlrLayer.Background
            keyboardFocus: WlrKeyboardFocus.OnDemand
            namespace: "quickshell-home"
            visible: true
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusiveZone: 40 // used for wallpaper and that bar so that bar can overlap and wallpaper never pushed none
            color: "transparent"

            // scaling
            Item {
                id: wallpaperContainer
                anchors.fill: parent
                scale: wallskiRef.isHovered ? 1.025 : 1.0 // when that wallski is opened zoom in the wallpaper here
                transformOrigin: Item.Center
                clip: true

                Behavior on scale {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }

                layer.enabled: wallskiRef.isHovered

                // main wallpaper
                Item {
                    id: wallpaperWrapper
                    anchors.fill: parent
                    clip: true

                    Image {
                        id: wallpaper
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        source: ""
                        cache: false
                        fillMode: Image.PreserveAspectCrop

                        property real mouseXNormalized: 0.5
                        property bool isPannable: false
                        property real calculatedWidth: parent.width

                        onStatusChanged: {
                            if (status === Image.Ready) {
                                const imgAspect = implicitWidth / implicitHeight;
                                const screenAspect = parent.width / parent.height;
                                const isWide = imgAspect > screenAspect * 1.1;

                                isPannable = isWide;

                                if (isWide) {
                                    calculatedWidth = implicitWidth * (parent.height / implicitHeight);
                                } else {
                                    calculatedWidth = parent.width;
                                }
                            }
                        }

                        width: calculatedWidth

                        x: {
                            if (!isPannable)
                                return 0;
                            const maxOffset = width - parent.width;
                            return -maxOffset * mouseXNormalized;
                        }

                        Behavior on x {
                            enabled: wallpaper.isPannable
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true

                            onMouseXChanged: {
                                if (wallpaper.isPannable) {
                                    wallpaper.mouseXNormalized = mouseX / width;
                                }
                            }
                        }

                        Component.onCompleted: {
                            source = Dat.WallpaperConfig.currentWallpaper;

                            Dat.WallpaperConfig.currentWallpaperChanged.connect(() => {
                                if (walAnimation.running) {
                                    walAnimation.complete();
                                }
                                animatingWal.source = Dat.WallpaperConfig.currentWallpaper;
                            });

                            animatingWal.statusChanged.connect(() => {
                                if (animatingWal.status === Image.Ready) {
                                    walAnimation.start();
                                }
                            });

                            walAnimation.finished.connect(() => {
                                wallpaper.source = animatingWal.source;
                                animatingWal.source = "";
                                animationRect.width = 0;
                            });
                        }
                    }
                }

                // animation container
                Rectangle {
                    id: animationRect
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    clip: true
                    color: "transparent"
                    width: 0

                    NumberAnimation {
                        id: walAnimation
                        duration: 800
                        easing.type: Easing.OutCubic
                        from: 0
                        property: "width"
                        target: animationRect
                        to: homeLayer.width
                    }

                    Item {
                        anchors.fill: parent
                        clip: true

                        Image {
                            id: animatingWal
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height
                            source: ""
                            cache: false
                            fillMode: Image.PreserveAspectCrop

                            property bool isPannable: false
                            property real calculatedWidth: parent.parent.parent.width

                            onStatusChanged: {
                                if (status === Image.Ready) {
                                    const imgAspect = implicitWidth / implicitHeight;
                                    const screenAspect = parent.parent.parent.width / parent.height;
                                    const isWide = imgAspect > screenAspect * 1.1;

                                    isPannable = isWide;

                                    if (isWide) {
                                        calculatedWidth = implicitWidth * (parent.height / implicitHeight);
                                    } else {
                                        calculatedWidth = parent.parent.parent.width;
                                    }
                                }
                            }

                            width: calculatedWidth

                            x: {
                                if (!isPannable)
                                    return 0;
                                const maxOffset = width - parent.parent.parent.width;
                                return -maxOffset * wallpaper.mouseXNormalized;
                            }

                            Behavior on x {
                                enabled: animatingWal.isPannable
                                NumberAnimation {
                                    duration: 600
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }

            // dim overlay when wallski is open
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: wallskiRef.isHovered ? 0.3 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }
            }
            //notifications service
            Notification {
                id: notificationPopup
            }
            // wallski
            Wallski {
                id: wallskiRef
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 1440
            }
        }
    }
}
