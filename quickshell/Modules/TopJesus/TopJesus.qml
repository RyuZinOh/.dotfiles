import QtQuick
// import Qt5Compat.GraphicalEffects
import qs.Services.Shapes
import qs.Services.Theme
import qs.Modules.TopJesus.ControlRoom
import qs.Components.workspace
import qs.Components.ymdt
import qs.Modules.TopJesus.Wset
import qs.Modules.TopJesus.MAL
import qs.Components.battery
import qs.Components.Icon
import Quickshell

Item {
    id: root
    //enable this for extra pin stuff [very interesthing]
    PanelWindow {
        anchors.top: true
        implicitWidth: 0
        implicitHeight: 0
        exclusiveZone: 40
        visible: root.isPinned
    }

    implicitWidth: 1440
    implicitHeight: popout.height + nestedPopout.height
    width: implicitWidth
    height: implicitHeight

    property bool isHovered: false
    property bool isPinned: false
    property int activePopout: 0

    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        hoverEnabled: true

        onEntered: {
            root.isHovered = true;
        }
    }

  // was testing but creates a good background dropshadow somehow lol
    // FastBlur {
    //     anchors.fill: popout
    //     source: popout
    //     radius: 24
    //     transparentBorder: true
    // }
    PopoutShape {
        id: popout
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: 1440
        height: (isHovered || isPinned) ? 40 : 0

        alignment: 0
        radius: 20
        color: Theme.surfaceContainer

        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 10
            opacity: (isHovered || isPinned) ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            Workspace {
                id: workspaces
                bgOva: "transparent"
                height: 50
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                workspaceSize: 40
                spacing: 12
                showNumbers: true
            }

            Row {
                id: rightPanel
                spacing: 20
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: pinMouseArea.containsMouse ? Theme.surfaceBright : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰐃"
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 16
                        color: root.isPinned ? Theme.primaryColor : Theme.onSurfaceVariant
                        rotation: root.isPinned ? 0 : 45

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: pinMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.isPinned = !root.isPinned;
                        }
                    }
                }

                Battery {
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: cpuIconArea
                    width: 28
                    height: 28
                    radius: 6
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Icon {
                        name: "onigiri"
                        size: 24
                        color: cpuMouseArea.containsMouse ? Theme.primaryColor : Theme.onSurfaceVariant
                        anchors.centerIn: parent

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    MouseArea {
                        id: cpuMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            hoverTimer.stop();
                            root.activePopout = 1;
                        }

                        onExited: {
                            hoverTimer.restart();
                        }
                    }
                }

                Rectangle {
                    id: anilistIconArea
                    width: 28
                    height: 28
                    radius: 6
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Icon {
                        name: "feather"
                        size: 24
                        color: anilistMouseArea.containsMouse ? Theme.primaryColor : Theme.onSurfaceVariant
                        anchors.centerIn: parent

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    MouseArea {
                        id: anilistMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            hoverTimer.stop();
                            root.activePopout = 3;
                        }

                        onExited: {
                            hoverTimer.restart();
                        }
                    }
                }

                Rectangle {
                    id: settingsIconArea
                    width: 28
                    height: 28
                    radius: 6
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Icon {
                        name: "gear"
                        size: 24
                        color: settingsMouseArea.containsMouse ? Theme.primaryColor : Theme.onSurfaceVariant
                        anchors.centerIn: parent
                        rotation: settingsMouseArea.containsMouse ? 90 : 0

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        id: settingsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            hoverTimer.stop();
                            root.activePopout = 2;
                        }

                        onExited: {
                            hoverTimer.restart();
                        }
                    }
                }

                DayWidget {
                    font.family: "0xProto Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    ClockWidget {
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 14
                        color: Theme.onSurface
                    }

                    DateWidget {
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 14
                        color: Theme.onSurface
                    }
                }
            }
        }
    }

    Timer {
        id: hoverTimer
        interval: 150
        onTriggered: {
            root.activePopout = 0;
        }
    }

    PopoutShape {
        id: nestedPopout
        anchors.top: popout.bottom
        anchors.topMargin: 0

        property int lastActive: 1
        property bool isAnimating: widthAnim.running || heightAnim.running

        onVisibleChanged: {
            if (visible && activePopout > 0) {
                lastActive = activePopout;
            }
        }

        readonly property real targetWidth: {
            if (activePopout === 1) {
                return 700;
            }
            if (activePopout === 2) {
                return 380;
            }
            if (activePopout === 3) {
                return 400;
            }
            return (lastActive === 1) ? 700 : (lastActive === 2) ? 380 : 395;
        }

        readonly property real targetHeight: {
            if (activePopout === 1) {
                return 240;
            }
            if (activePopout === 2) {
                return 300;
            }
            if (activePopout === 3) {
                return 320;
            }
            return 0;
        }

        readonly property real targetX: {
            var popoutToUse = activePopout > 0 ? activePopout : lastActive;
            if (popoutToUse === 1) {
                return parent.width - targetWidth - 50;
            }
            if (popoutToUse === 2) {
                return parent.width - targetWidth - 250;
            }
            if (popoutToUse === 3) {
                return parent.width - targetWidth - 50;
            }
            return (parent.width - targetWidth) / 2;
        }

        width: targetWidth
        height: targetHeight
        x: targetX

        alignment: 0
        radius: 20
        color: Theme.surfaceContainer
        visible: height > 1 || isAnimating

        Behavior on width {
            enabled: activePopout > 0
            NumberAnimation {
                id: widthAnim
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on height {
            NumberAnimation {
                id: heightAnim
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on x {
            enabled: activePopout > 0
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    hoverTimer.stop();
                } else {
                    hoverTimer.restart();
                }
            }
        }

        Item {
            anchors.fill: parent
            clip: true

            Loader {
                id: controlRoomLoader
                anchors.centerIn: parent
                width: 670
                height: 210
                active: activePopout === 1
                asynchronous: true
                opacity: activePopout === 1 ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                sourceComponent: Component {
                    ControlRoom {}
                }
            }

            Loader {
                id: settingsLoader
                anchors.fill: parent
                anchors.margins: 10
                active: activePopout === 2
                asynchronous: true
                opacity: activePopout === 2 ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                sourceComponent: Component {
                    Wset {}
                }
            }

            Loader {
                id: anilistLoader
                anchors.fill: parent
                anchors.margins: 10
                active: true
                asynchronous: false
                opacity: activePopout === 3 ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                sourceComponent: Component {
                    Anilist {}
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            root.isHovered = hovered;
            if (!hovered) {
                root.activePopout = 0;
            }
        }
    }
}
