import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Services
import qs.Components.ContextMenu
import qs.Components.Wallski

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
                anchors.fill: parent
            }

            //touchpad gestured right click contextmenu [Just like Windows]
            ContextMenu {}

            // wallski direct
            Wallski {
                id: wallskiRef
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
