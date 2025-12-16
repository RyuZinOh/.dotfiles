import QtQuick
import Quickshell.Widgets
import qs.Data as Dat

Item {
    id: wallpaperService

    // public properties
    property bool enablePanning: true
    property bool enableZoomEffect: true
    property int crossfadeDuration: 1000
    property int zoomDuration: 1200

    //transition types
    property string transitionType: "crossfade"

    // scaling
    property bool isHovered: false
    property real hoverScale: isHovered ? 1.06 : 1

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
            cache: true
            asynchronous: true //block prevention
            fillMode: Image.PreserveAspectCrop

            property real mouseXNormalized: 0.5
            property bool isPannable: false
            property real calculatedWidth: parent.width

            onStatusChanged: {
                if (status === Image.Ready) {
                    const imgAspect = implicitWidth / implicitHeight;
                    const screenAspect = parent.width / parent.height;
                    const isWide = imgAspect > screenAspect * 1.1;

                    isPannable = isWide && enablePanning;

                    if (isWide) {
                        calculatedWidth = implicitWidth * (parent.height / implicitHeight);
                    } else {
                        calculatedWidth = parent.width;
                    }
                }
            }

            width: calculatedWidth

            x: {
                if (!isPannable) {
                    return 0;
                }
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

                    if (transitionType === "crossfade") {
                        if (crossfadeAnimation.running) {
                            crossfadeAnimation.complete();
                        }
                        animatingWal.source = newWallpaper;
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

                animatingWal.statusChanged.connect(() => {
                    if (animatingWal.status === Image.Ready) {
                        crossfadeAnimation.start();
                    }
                });

                crossfadeAnimation.finished.connect(() => {
                    wallpaper.source = animatingWal.source;
                    animatingWal.source = "";
                    animatingWal.opacity = 0;
                    animatingWal.scale = 1.0;
                });

                bubbleAnimation.finished.connect(() => {
                    wallpaper.source = bubbleWallpaper.source;
                    bubbleWallpaper.source = "";
                    bubbleClip.diameter = 0;
                });
            }
        }

        //crossfade zoom
        Image {
            id: animatingWal
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            source: ""
            cache: true
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            opacity: 0
            scale: enableZoomEffect ? 1.1 : 1.0
            visible: transitionType === "crossfade" && source !== ""

            property bool isPannable: false
            property real calculatedWidth: parent.width

            onStatusChanged: {
                if (status === Image.Ready) {
                    const imgAspect = implicitWidth / implicitHeight;
                    const screenAspect = parent.width / parent.height;
                    const isWide = imgAspect > screenAspect * 1.1;

                    isPannable = isWide && enablePanning;

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
                return -maxOffset * wallpaper.mouseXNormalized;
            }

            Behavior on x {
                enabled: animatingWal.isPannable
                NumberAnimation {
                    duration: 600
                    easing.type: Easing.OutCubic
                }
            }

            ParallelAnimation {
                id: crossfadeAnimation

                NumberAnimation {
                    target: animatingWal
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: wallpaperService.crossfadeDuration
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    target: animatingWal
                    property: "scale"
                    from: enableZoomEffect ? 1.1 : 1.0
                    to: 1.0
                    duration: wallpaperService.zoomDuration
                    easing.type: Easing.OutCubic
                }
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
                    duration: wallpaperService.crossfadeDuration
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
                    cache: true
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
    }
}
