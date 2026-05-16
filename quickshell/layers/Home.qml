import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components.ContextMenu
import qs.Components.Wallski
import qs.Services
import qs.Components.PaimonClock
import qs.utils

Scope {
    // background layer [wallpaper]
    Variants {
        model: Quickshell.screens

        WlrLayershell {
            id: homeLayer
            // PanelWindow {
            //     anchors.top: true
            //     implicitWidth: 0
            //     implicitHeight: 0
            //     exclusiveZone: 40
            //     visible: true
            // }
            Component.onCompleted: {
                PaimonClockConfig.screenWidth = homeLayer.screen.width;
                PaimonClockConfig.screenHeight = homeLayer.screen.height;
            }

            required property var modelData

            screen: modelData
            layer: WlrLayer.Background
            keyboardFocus: WlrKeyboardFocus.OnDemand // this one when left commented we can't basically filter in our wallski, if opened, wont let the window to grab toe keyboard for certain amount of time [feature xD]
            namespace: "quickshell-home"
            visible: true
            exclusiveZone: ExclusionMode.Ignore
            color: "transparent"

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

            //wallpaperService
            WallpaperService {
                anchors.fill: parent
            }

            Loader {
                id: paimonClockLoader
                active: PaimonClockConfig.isActive
                sourceComponent: PaimonClock {}
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
