import QtQuick
import Quickshell.Widgets
import qs.Data as Dat

Item {
    id: wallpaperService

    // public properties
    property bool enablePanning: true
    property int bubbleDuration: 1000

    //transition types
    property string transitionType: "instant"

    // scaling
    property bool isHovered: false
    property real hoverScale: isHovered ? 1.06 : 1
    property bool isFirstLoad: true

    anchors.fill: parent
    scale: hoverScale
    transformOrigin: Item.Center
    clip: true

    Behavior on scale {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    layer.enabled: isHovered

    Item {
        id: wallpaperWrapper
        anchors.fill: parent
        clip: true

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

            onStatusChanged: {
                if (status === Image.Ready) {
                    const imgAspect = implicitWidth / implicitHeight;
                    const screenAspect = parent.width / parent.height;
                    const isWide = imgAspect > screenAspect * 1.1;

                    isPannable = isWide && enablePanning;
                    calculatedWidth = isWide ? implicitWidth * (parent.height / implicitHeight) : parent.width;

                    if (transitionType === "bubble" && isTransitioning) {
                        isTransitioning = false;
                        bubbleWallpaper.source = "";
                        bubbleClip.diameter = 0;
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
                const initialWallpaper = Dat.WallpaperConfig.currentWallpaper;
                if (initialWallpaper) {
                    source = initialWallpaper;
                }

                Dat.WallpaperConfig.currentWallpaperChanged.connect(() => {
                    const newWallpaper = Dat.WallpaperConfig.currentWallpaper;

                    //skipping if same wallpaper
                    if (newWallpaper === wallpaper.source) {
                        return;
                    }

                    if (isFirstLoad) {
                        wallpaper.source = newWallpaper;
                        isFirstLoad = false;
                        return;
                    }

                    if (transitionType === "instant") {
                        wallpaper.source = newWallpaper;
                    } else if (transitionType === "bubble") {
                        if (bubbleAnimation.running) {
                            bubbleAnimation.complete();
                        }
                        // randomize bubble origin
                        bubbleClip.originX = Math.random() * wallpaperService.width;
                        bubbleClip.originY = Math.random() * wallpaperService.height;
                        bubbleWallpaper.source = newWallpaper;
                        bubbleAnimation.start();
                    }
                });

                bubbleAnimation.finished.connect(() => {
                    wallpaper.isTransitioning = true;
                    wallpaper.source = bubbleWallpaper.source;
                });
            }
        }

        //bubble transition
        Item {
            anchors.fill: parent
            visible: transitionType === "bubble" && bubbleWallpaper.source !== ""
            clip: true

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
                        // Calculate the maximum distance from the random origin to any corner
                        const dx1 = bubbleClip.originX;
                        const dx2 = wallpaperService.width - bubbleClip.originX;
                        const dy1 = bubbleClip.originY;
                        const dy2 = wallpaperService.height - bubbleClip.originY;

                        const maxDx = Math.max(dx1, dx2);
                        const maxDy = Math.max(dy1, dy2);

                        return Math.sqrt(maxDx * maxDx + maxDy * maxDy) * 2.2;
                    }
                    duration: wallpaperService.bubbleDuration
                    easing.type: Easing.Bezier
                    easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
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
                }
            }
        }
    }
}
