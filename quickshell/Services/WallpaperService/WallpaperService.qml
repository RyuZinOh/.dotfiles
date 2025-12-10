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
    property real hoverScale: isHovered ? 1.10 : 1

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
                source = Dat.WallpaperConfig.currentWallpaper;

                Dat.WallpaperConfig.currentWallpaperChanged.connect(() => {
                    if (transitionType === "crossfade") {
                        if (crossfadeAnimation.running) {
                            crossfadeAnimation.complete();
                        }
                        animatingWal.source = Dat.WallpaperConfig.currentWallpaper;
                    } else if (transitionType === "bubble") {
                        if (bubbleAnimation.running) {
                            bubbleAnimation.complete();
                        }
                        bubbleWallpaper.source = Dat.WallpaperConfig.currentWallpaper;
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
                    bubbleClip.width = 0;
                });
            }
        }

        //crossfade zoom
        Image {
            id: animatingWal
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            source: ""
            cache: false
            fillMode: Image.PreserveAspectCrop
            opacity: 0
            scale: enableZoomEffect ? 1.1 : 1.0
            visible: transitionType === "crossfade"

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
        ClippingRectangle {
            id: bubbleClip
            anchors.centerIn: parent
            width: 0
            height: width
            visible: transitionType === "bubble"
            color: "transparent"
            radius: width
            layer.smooth: true

            NumberAnimation {
                id: bubbleAnimation
                target: bubbleClip
                property: "width"
                from: 0
                to: Math.max(wallpaperService.width, wallpaperService.height) * 1.5
                duration: wallpaperService.crossfadeDuration
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
            }

            Image {
                id: bubbleWallpaper
                anchors.centerIn: parent
                width: wallpaperService.width
                height: wallpaperService.height
                source: ""
                cache: false
                fillMode: Image.PreserveAspectCrop
            }
        }
    }
}
