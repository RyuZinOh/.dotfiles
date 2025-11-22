import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Modules.Wallski
import qs.Modules.Pictorial
import qs.Services.Notification
import qs.Services.WallpaperService
// import qs.Modules.Streaks
import qs.Modules.MAL
import qs.Modules.KuruKuru

Scope {
    // background layer [wallpaper]
    Variants {
        model: Quickshell.screens
        WlrLayershell {
            id: homeLayer
            required property var modelData
            screen: modelData
            layer: WlrLayer.Background
            keyboardFocus: WlrKeyboardFocus.OnDemand // this one when left commented we can't basically filter in our wallski, if opened, wont let the window to grab toe keyboard for certain amount of time [feature xD]
            namespace: "quickshell-home"
            visible: true
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusiveZone: ExclusionMode.Ignore
            color: "transparent"

            //wallpaperService
            WallpaperService {
                id: wallpaperService
                anchors.fill: parent
                isHovered: wallskiRef.isHovered

                //customs
                enablePanning: true
                enableZoomEffect: true
                crossfadeDuration: 1000
                zoomDuration: 1200
                transitionType: "crossfade"
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
                width: 999
            }
            // kururin leftbottom
            Kururin {
                id: kuruRef
                anchors.left: parent.left
                anchors.bottom: parent.bottom
            }

            // pictorial at right-bottom side
            Pictorial {
                id: pictorialRef
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }

            //right side streak
            //github [not much of a use tbh]
            // Github {
            //     id: gitSRef
            //     anchors.right: parent.right
            //     anchors.verticalCenter: parent.verticalCenter
            //     anchors.verticalCenterOffset: 300
            // }

            //anilist but contains todolist as well
            Anilist {
                id: aniRef
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
