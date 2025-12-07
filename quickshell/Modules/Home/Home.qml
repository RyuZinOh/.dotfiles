import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Modules.Setski
import qs.Modules.Pictorial
import qs.Services.WallpaperService
// import qs.Services.Music
// import qs.Modules.Streaks
import qs.Modules.MAL
import qs.Modules.KuruKuru
// import qs.Modules.Clipstory
import qs.Modules.ContextMenu

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
                isHovered: setskiRef.isHovered

                //customs
                enablePanning: true
                enableZoomEffect: true
                crossfadeDuration: 1000
                zoomDuration: 1200
                transitionType: "crossfade"
            }

            //touchpad gestured right click contextmenu [Just like Windows]
            ContextMenu {}
            // dim overlay when setski is open
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: setskiRef.isHovered ? 0.3 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }
            }
            // [just showcase stuff tbh, not really practical but yea uncomment to use it]
            // Controller {
            //     id: musicController
            //     anchors {
            //         right: parent.right
            //         verticalCenter: parent.verticalCenter
            //     }
            // }

            // clip history [planned- for storing the copied stuff as clipboarding]
            // Clipstory {
            //     id: clipstoryRef
            // }
            // setski
            Setski {
                id: setskiRef
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
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
