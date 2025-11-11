import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.components

//continer for the popupShape yea, its transparent
PanelWindow {
    id: binbow
    //exposing the API
    property alias expanded: popup.expanded
    property alias hovered: popup.hovered
    property alias hideT: hideT
    function toggle(show) {
        popup.toggle(show);
    }

    //configuration properties for modifying
    readonly property int topBarHeight: 40
    readonly property int maxBarWidth: 1440
    readonly property int screenPadding: 0
    readonly property int leftOffset: 250

    //states
    QtObject {
        id: popup
        property bool expanded: false
        property bool hovered: false

        function toggle(show) {
            if (show) {
                if (expanded) {
                    return;
                }
                expanded = hovered = true;
                binbow.visible = true;
                hideT.stop();
            } else if (!hovered) {
                expanded = false;
                closeT.start();
            }
        }
    }

    Timer {
        id: hideT
        interval: 200
        onTriggered: popup.toggle(false)
    }

    Timer {
        id: closeT
        interval: 215 // ha some animation so like like all we wil try to fall back so syncing will will cause glitch
        onTriggered: {
            if (!popup.expanded && !popup.hovered) {
                binbow.visible = false;
            }
        }
    }
    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    screen: Quickshell.screens[0]

    implicitWidth: 250
    implicitHeight: 200

    anchors.top: true
    anchors.left: true
    margins.top: 40 //correspondigly to the topbar at Bar.qml
    margins.left: {
        const screenWidth = screen.width;
        let barW = Math.min(maxBarWidth, screenWidth - screenPadding);
        let barL = (screenWidth - barW) / 2;
        return barL + leftOffset;
    }

    PopoutShape {
        id: panel
        anchors.fill: parent
        radius: 10
        color: "black"
        style: 1
        alignment: 0
        clip: true

        height: popup.expanded ? 200 : 0

        //some random animzation only for verticals
        transform: Scale {
            origin.x: panel.width / 2
            origin.y: 0
            xScale: 1.0
            yScale: popup.expanded ? 1.0 : 0.0

            Behavior on yScale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 20
            width: 200
            opacity: popup.expanded ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
            // [took inspiration from my ryuzinoh sddm, for circular bg, but with OpacityMask instead of multiEffect]
            BrightnessControl {
                width: parent.width
                height: 50
            }
            VolumeControl {
                width: parent.width
                height: 50
            }
        }

        /*
         track mouse intreaction
         - covering entire panel for ease reacting when just jovering at the position [from arch to workspace]
         - when entered stop the hiding timer so there so it stays
         - else, hidetimer will continue [hovering will be at along with popupShape]
         */
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            // cursorShape: Qt.PointingHandCursor
            onEntered: {
                popup.hovered = true;
                hideT.stop();
                closeT.stop();
            }
            onExited: {
                popup.hovered = false;
                hideT.restart();
            }
        }
    }
}
