import QtQuick
// import Qt5Compat.GraphicalEffects
import qs.Services.Shapes
import qs.Services.Theme
import qs.Modules.TopJesus.ControlRoom
import qs.Components.workspace
import qs.Components.ymdt
import qs.Modules.TopJesus.Wset
import qs.Modules.TopJesus.MAL
import qs.Modules.TopJesus.Powerski
import qs.Components.battery
import qs.Modules.TopJesus.Callgorl
import qs.Components.Icon

// import Quickshell

Item {
    id: root
    //enable this for extra pin stuff [very interesthing]
    // PanelWindow {
    //     anchors.top: true
    //     implicitWidth: 0
    //     implicitHeight: 0
    //     exclusiveZone: 40
    //     visible: root.isPinned
    // }
    implicitWidth: 1440
    implicitHeight: popout.height + nestedPopout.height
    width: implicitWidth
    height: implicitHeight

    property bool isHovered: false
    property bool isPinned: false
    property int activePopout: 0

    onActivePopoutChanged: {
        if (activePopout > 0) {
            nestedPopout.lastActive = activePopout;
        }
    }

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
                duration: 200
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
                anchors.verticalCenter: parent.verticalCenter
                workspaceSize: 40
                showNumbers: true
            }

            Row {
                id: rightPanel
                spacing: 10
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

                Item {
                    id: popoutIconRowContainer
                    width: popoutIconRow.width
                    height: 28
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: popoutIconRow
                        width: iconRowContent.width + 20
                        height: 32
                        radius: 8
                        color: root.activePopout > 0 ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                        border.color: root.activePopout > 0 ? Theme.primaryColor : Theme.outlineVariant
                        border.width: root.activePopout > 0 ? 1 : 0.5
                        anchors.centerIn: parent

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Behavior on border.width {
                            NumberAnimation {
                                duration: 200
                            }
                        }

                        Row {
                            id: iconRowContent
                            anchors.centerIn: parent

                            Rectangle {
                                id: cpuIconArea
                                width: 36
                                height: 28
                                radius: 6
                                color: "transparent"

                                Icon {
                                    name: "onigiri"
                                    size: 20
                                    color: root.activePopout === 1 ? Theme.primaryColor : (cpuMouseArea.containsMouse ? Theme.onPrimaryContainer : Theme.onSurfaceVariant)
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
                                        root.activePopout = 1;
                                    }
                                }
                            }

                            Rectangle {
                                id: settingsIconArea
                                width: 36
                                height: 28
                                radius: 6
                                color: "transparent"

                                Icon {
                                    name: "gear"
                                    size: 20
                                    color: root.activePopout === 2 ? Theme.primaryColor : (settingsMouseArea.containsMouse ? Theme.onPrimaryContainer : Theme.onSurfaceVariant)
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
                                        root.activePopout = 2;
                                    }
                                }
                            }

                            Rectangle {
                                id: anilistIconArea
                                width: 36
                                height: 28
                                radius: 6
                                color: "transparent"

                                Icon {
                                    name: "feather"
                                    size: 20
                                    color: root.activePopout === 3 ? Theme.primaryColor : (anilistMouseArea.containsMouse ? Theme.onPrimaryContainer : Theme.onSurfaceVariant)
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
                                        root.activePopout = 3;
                                    }
                                }
                            }

                            Rectangle {
                                id: desktopIconArea
                                width: 36
                                height: 28
                                radius: 6
                                color: "transparent"

                                Icon {
                                    name: "desktop"
                                    size: 20
                                    color: root.activePopout === 4 ? Theme.primaryColor : (desktopMouseArea.containsMouse ? Theme.onPrimaryContainer : Theme.onSurfaceVariant)
                                    anchors.centerIn: parent

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                }

                                MouseArea {
                                    id: desktopMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onEntered: {
                                        root.activePopout = 4;
                                    }
                                }
                            }

                            Rectangle {
                                id: dancerIconArea
                                width: 36
                                height: 28
                                radius: 6
                                color: "transparent"

                                Icon {
                                    name: "plug"
                                    size: 20
                                    color: root.activePopout === 5 ? Theme.primaryColor : (dancerMouseArea.containsMouse ? Theme.onPrimaryContainer : Theme.onSurfaceVariant)
                                    anchors.centerIn: parent

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                }

                                MouseArea {
                                    id: dancerMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onEntered: {
                                        root.activePopout = 5;
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: hoverBridge
                        anchors.top: popoutIconRow.bottom
                        anchors.horizontalCenter: popoutIconRow.horizontalCenter
                        width: popoutIconRow.width
                        height: 10
                        color: "transparent"
                        visible: root.activePopout > 0

                        HoverHandler {
                            onHoveredChanged: {
                                if (hovered) {
                                    hoverTimer.stop();
                                } else {
                                    hoverTimer.restart();
                                }
                            }
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
            if (activePopout === 0) {
                if (lastActive === 1) {
                    return 700;
                }
                if (lastActive === 2) {
                    return 380;
                }
                if (lastActive === 3) {
                    return 400;
                }
                if (lastActive === 4) {
                    return 400;
                }
                if (lastActive === 5) {
                    return 320;
                }
                return 700;
            }
            if (activePopout === 1) {
                return 700;
            }
            if (activePopout === 2) {
                return 380;
            }
            if (activePopout === 3) {
                return 400;
            }
            if (activePopout === 4) {
                return 400;
            }
            if (activePopout === 5) {
                return 320;
            }
            return 700;
        }

        readonly property real targetHeight: {
            if (activePopout === 0) {
                return 0;
            }
            if (activePopout === 1) {
                return 240;
            }
            if (activePopout === 2) {
                return 300;
            }
            if (activePopout === 3) {
                return 320;
            }
            if (activePopout === 4) {
                return 200;
            }
            if (activePopout === 5) {
                return 240;
            }
            return 0;
        }

        readonly property real targetX: {
            var popoutToUse = activePopout > 0 ? activePopout : lastActive;
            if (popoutToUse === 1) {
                return parent.width - targetWidth - 75;
            }
            if (popoutToUse === 2) {
                return parent.width - targetWidth - 200;
            }
            if (popoutToUse === 3) {
                return parent.width - targetWidth - 200;
            }
            if (popoutToUse === 4) {
                return parent.width - targetWidth - 225;
            }
            if (popoutToUse === 5) {
                return parent.width - targetWidth - 200;
            }
            return parent.width - targetWidth - 50;
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

            Loader {
                id: powerLoader
                anchors.fill: parent
                anchors.margins: 10
                active: activePopout === 4
                asynchronous: true
                opacity: activePopout === 4 ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                sourceComponent: Component {
                    Powerski {}
                }
            }

            Loader {
                id: callgorlLoader
                anchors.fill: parent
                anchors.margins: 10
                active: activePopout === 5
                asynchronous: true
                opacity: activePopout === 5 ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                sourceComponent: Component {
                    Callgorl {}
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
