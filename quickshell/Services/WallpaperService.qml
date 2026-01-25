import QtQuick
import Quickshell.Widgets
import qs.Services.Theme
import qs.utils

Item {
    id: wallpaperService

    anchors.fill: parent
    clip: true

    Rectangle {
        id: minimalBackground
        anchors.fill: parent
        color: Theme.primaryColor
        visible: WallpaperConfig.displayMode === "minimal"
    }

    Loader {
        id: wallpaperLoader
        anchors.fill: parent
        active: WallpaperConfig.displayMode === "wallpaper"
        asynchronous: true

        sourceComponent: Item {
            id: wallpaperContainer
            anchors.fill: parent
            clip: true

            property bool componentActive: true

            Component.onDestruction: {
                componentActive = false;
            }
            //preloading to prevent blackflash
            Image {
                id: preloadWallpaper
                visible: false
                cache: false
                asynchronous: true

                onStatusChanged: {
                    if (!parent || !wallpaperContainer || !wallpaperContainer.componentActive) {
                        return;
                    }
                    if (status === Image.Ready && WallpaperConfig.transitionType === "instant") {
                        wallpaper.source = source;
                    }
                }

                Component.onDestruction: {
                    source = "";
                }
            }
            // main wallpaper
            Image {
                id: wallpaper
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                source: ""
                cache: false
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: parent.width
                sourceSize.height: parent.height

                property real mouseXNormalized: 0.5
                property bool isPannable: false
                property real calculatedWidth: parent.width
                property bool isTransitioning: false
                property bool bubbleTransitionActive: false

                onStatusChanged: {
                    if (!parent || !wallpaperContainer || !wallpaperContainer.componentActive) {
                        return;
                    }
                    if (status === Image.Ready) {
                        const imgAspect = implicitWidth / implicitHeight;
                        const screenAspect = parent.width / parent.height;
                        const isWide = imgAspect > screenAspect * 1.1;
                        isPannable = isWide && WallpaperConfig.enablePanning;
                        calculatedWidth = isWide ? implicitWidth * (parent.height / implicitHeight) : parent.width;

                        if (WallpaperConfig.transitionType === "bubble" && isTransitioning) {
                            isTransitioning = false;
                            bubbleTransitionItem.cleanup();
                        }
                    }
                }

                width: calculatedWidth

                x: {
                    if (!isPannable) {
                        return 0;
                    }
                    return -(width - parent.width) * mouseXNormalized;
                }

                Behavior on x {
                    enabled: wallpaper.isPannable && wallpaperContainer && wallpaperContainer.componentActive
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    enabled: wallpaperContainer && wallpaperContainer.componentActive

                    onMouseXChanged: {
                        if (wallpaper.isPannable && wallpaperContainer && wallpaperContainer.componentActive) {
                            wallpaper.mouseXNormalized = mouseX / width;
                        }
                    }
                }

                Connections {
                    target: WallpaperConfig

                    function onEnablePanningChanged() {
                        if (!wallpaperContainer || !wallpaperContainer.componentActive) {
                            return;
                        }
                        const imgAspect = wallpaper.implicitWidth / wallpaper.implicitHeight;
                        const screenAspect = wallpaper.parent.width / wallpaper.parent.height;
                        const isWide = imgAspect > screenAspect * 1.1;
                        wallpaper.isPannable = isWide && WallpaperConfig.enablePanning;

                        if (!WallpaperConfig.enablePanning) {
                            wallpaper.mouseXNormalized = 0.5;
                        }
                    }
                }

                Component.onCompleted: {
                    const setInitialWallpaper = () => {
                        if (WallpaperConfig.currentWallpaper) {
                            source = WallpaperConfig.currentWallpaper;
                        }
                    };

                    if (WallpaperConfig.loaded) {
                        setInitialWallpaper();
                    } else {
                        const connection = WallpaperConfig.loadedChanged.connect(() => {
                            if (WallpaperConfig.loaded) {
                                setInitialWallpaper();
                                connection.disconnect();
                            }
                        });
                    }

                    WallpaperConfig.currentWallpaperChanged.connect(() => {
                        if (!wallpaperContainer || !wallpaperContainer.componentActive) {
                            return;
                        }

                        const newWallpaper = WallpaperConfig.currentWallpaper;
                        //skipping if same wallpaper
                        if (newWallpaper === wallpaper.source) {
                            return;
                        }

                        if (WallpaperConfig.transitionType === "instant") {
                            preloadWallpaper.source = newWallpaper;
                        } else if (WallpaperConfig.transitionType === "bubble") {
                            wallpaper.bubbleTransitionActive = true;
                            bubbleTransitionItem.startTransition(newWallpaper);
                        }
                    });

                    bubbleAnimation.finished.connect(() => {
                        if (wallpaperContainer && wallpaperContainer.componentActive && wallpaper.bubbleTransitionActive) {
                            wallpaper.isTransitioning = true;
                            wallpaper.source = bubbleWallpaper.source;
                            wallpaper.bubbleTransitionActive = false;
                        }
                    });
                }

                Component.onDestruction: {
                    source = "";
                }
            }

            Item {
                id: bubbleTransitionItem
                anchors.fill: parent
                visible: WallpaperConfig.transitionType === "bubble" && bubbleWallpaper.source !== ""
                clip: true

                function startTransition(newWallpaper) {
                    if (!wallpaperContainer || !wallpaperContainer.componentActive) {
                        return;
                    }
                    if (bubbleAnimation.running) {
                        bubbleAnimation.complete();
                    }
                    // randomize bubble origin
                    bubbleClip.originX = Math.random() * wallpaperService.width;
                    bubbleClip.originY = Math.random() * wallpaperService.height;
                    bubbleWallpaper.source = newWallpaper;
                    bubbleAnimation.start();
                }

                function cleanup() {
                    bubbleWallpaper.source = "";
                    bubbleClip.diameter = 0;
                }
                //bubble transition
                ClippingRectangle {
                    id: bubbleClip
                    property real originX: 0
                    property real originY: 0
                    property real diameter: 0
                    x: originX - diameter / 2
                    y: originY - diameter / 2
                    width: diameter
                    height: diameter
                    color: "transparent"
                    radius: diameter / 2
                    layer.smooth: true

                    NumberAnimation {
                        id: bubbleAnimation
                        target: bubbleClip
                        property: "diameter"
                        from: 0
                        to: {
                            if (!wallpaperContainer || !wallpaperContainer.componentActive) {
                                return 0;
                            }
                            // Calculate the maximum distance from the random origin to any corner
                            const dx1 = bubbleClip.originX;
                            const dx2 = wallpaperService.width - bubbleClip.originX;
                            const dy1 = bubbleClip.originY;
                            const dy2 = wallpaperService.height - bubbleClip.originY;
                            const maxDx = Math.max(dx1, dx2);
                            const maxDy = Math.max(dy1, dy2);
                            return Math.sqrt(maxDx * maxDx + maxDy * maxDy) * 2.2;
                        }
                        duration: WallpaperConfig.bubbleDuration
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                        running: wallpaperContainer && wallpaperContainer.componentActive
                    }

                    Image {
                        id: bubbleWallpaper
                        x: -bubbleClip.originX + bubbleClip.diameter / 2
                        y: -bubbleClip.originY + bubbleClip.diameter / 2
                        width: wallpaperService.width
                        height: wallpaperService.height
                        source: ""
                        cache: false
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: wallpaperService.width
                        sourceSize.height: wallpaperService.height
                        Component.onDestruction: {
                            source = "";
                        }
                    }
                }
            }
        }
    }
}
