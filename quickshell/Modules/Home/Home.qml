import Quickshell
import QtQuick
import Quickshell.Wayland
// import qs.Modules.Pictorial
import qs.Services.WallpaperService
import qs.Modules.MAL
// import qs.Modules.KuruKuru
import qs.Modules.ContextMenu
import qs.Modules.Wallski

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
            /*
             This is Useless until I fully develop project Ash which
             share bond to it as [A Helper/guid/friend] -> I am working on in this...
             */
            // PanelWindow {
            //     anchors.top: true
            //     implicitWidth: 0
            //     implicitHeight: 0
            //     exclusiveZone: 40
            //     visible: true
            // }

            exclusiveZone: ExclusionMode.Ignore
            color: "transparent"

            //wallpaperService
            WallpaperService {
                id: wallpaperService
                anchors.fill: parent
                isHovered: wallskiRef.isHovered

                //customs
                enablePanning: true
                transitionType: "bubble"
                // transitionType: "instant"
            }

            //touchpad gestured right click contextmenu [Just like Windows]
            ContextMenu {}
            // dim overlay when setski is open
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
            // wallski direct
            Wallski {
                id: wallskiRef
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // kururin leftbottom
            // Kururin {
            //     id: kuruRef
            //     anchors.left: parent.left
            //     anchors.bottom: parent.bottom
            // }

            // pictorial at right-bottom side
            // Pictorial {
            //     id: pictorialRef
            //     anchors.right: parent.right
            //     anchors.bottom: parent.bottom
            // }

            //anilist but contains todolist as well
            Anilist {
                id: aniRef
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
