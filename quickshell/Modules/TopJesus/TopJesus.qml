pragma ComponentBehavior: Bound
/*I dont want to use qs for importing in modules for some weird reasons, well*/
import "./Callgorl/"
import "./ControlRoom/"
import "./MAL/"
import "./Powerski/"
import "./Wset/"
import QtQuick
import qs.Components.topjesus
import qs.Services.Shapes
import qs.Services.Theme

Item {
    id: root

    required property var parentScreen
    property bool isHovered: false
    property bool isPinned: false
    property int activePopout: 0
    property var hoveredWayland: null
    property real previewX: 0
    property bool iconRowHovered: false
    property bool bridgeHovered: false
    property bool nestedHovered: false
    readonly property var popoutIcons: [{
        "id": 1,
        "icon": "\udb81\udfea",
        "xOff": 75,
        "w": 580,
        "h": 180
    }, {
        "id": 2,
        "icon": "\uefa7",
        "xOff": 200,
        "w": 320,
        "h": 200
    }, {
        "id": 3,
        "icon": "\uee34",
        "xOff": 200,
        "w": 450,
        "h": 400
    }, {
        "id": 4,
        "icon": "\uee82",
        "xOff": 225,
        "w": 320,
        "h": 110
    }, {
        "id": 5,
        "icon": "\udb81\udce0",
        "xOff": 200,
        "w": 320,
        "h": 110
    }]
    readonly property var popoutComponents: [null, controlRoomComp, wsetComp, anilistComp, powerskiComp, callgorlComp]

    function checkClose() {
        closeTimer.restart();
    }

    implicitWidth: 1440
    implicitHeight: popout.height + nestedPopout.height
    width: implicitWidth
    height: implicitHeight
    onActivePopoutChanged: {
        if (root.activePopout > 0) {
            nestedPopout.lastActive = root.activePopout;
            const c = root.popoutIcons.find((p) => {
                return p.id === root.activePopout;
            });
            const tx = root.width - c.w - c.xOff;
            if (!nestedPopout.hasOpenedOnce) {
                xBehavior.enabled = false;
                widthBehavior.enabled = false;
                nestedPopout.x = tx;
                nestedPopout.width = c.w;
                xBehavior.enabled = true;
                widthBehavior.enabled = true;
                nestedPopout.hasOpenedOnce = true;
            }
            nestedPopout.x = tx;
            nestedPopout.width = c.w;
            nestedPopout.height = c.h;
        } else {
            nestedPopout.height = 0;
        }
    }

    Timer {
        id: closeTimer

        interval: 250
        repeat: false
        onTriggered: {
            if (!root.iconRowHovered && !root.bridgeHovered && !root.nestedHovered)
                root.activePopout = 0;

        }
    }

    Component {
        id: controlRoomComp

        ControlRoom {
        }

    }

    Component {
        id: wsetComp

        Wset {
        }

    }

    Component {
        id: anilistComp

        Anilist {
        }

    }

    Component {
        id: powerskiComp

        Powerski {
        }

    }

    Component {
        id: callgorlComp

        Callgorl {
        }

    }

    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        hoverEnabled: true
        onEntered: root.isHovered = true
    }

    PopoutShape {
        id: popout

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 1440
        height: (root.isHovered || root.isPinned) ? 40 : 0
        alignment: 0
        clip: true
        radius: 20
        color: Theme.surfaceContainer

        Item {
            anchors.fill: parent
            anchors.margins: 10
            opacity: (root.isHovered || root.isPinned) ? 1 : 0

            Workspace {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                parentScreen: root.parentScreen
                workspaceSize: 40
                spacing: 0
            }

            Row {
                spacing: 10
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                // BongoCat {
                // size: 64
                // anchors.verticalCenter: parent.verticalCenter
                // }
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: pinArea.containsMouse ? Theme.surfaceBright : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "\uf08d"
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
                        id: pinArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.isPinned = !root.isPinned
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                Battery {
                    anchors.verticalCenter: parent.verticalCenter
                }

                TaskBar {
                    id: taskBar

                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    height: 28
                    width: iconRow.width
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: iconRow

                        height: 32
                        radius: 8
                        width: iconRowContent.width + 20
                        anchors.centerIn: parent
                        color: root.activePopout > 0 ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                        border.color: root.activePopout > 0 ? Theme.primaryColor : Theme.outlineVariant
                        border.width: root.activePopout > 0 ? 1 : 0.5

                        Row {
                            id: iconRowContent

                            anchors.centerIn: parent

                            Repeater {
                                model: root.popoutIcons

                                Rectangle {
                                    id: iconRect

                                    required property var modelData
                                    readonly property bool isGear: iconRect.modelData.id === 2

                                    width: 36
                                    height: 28
                                    radius: 6
                                    color: "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: iconRect.modelData.icon
                                        font.family: "CaskaydiaCove NF"
                                        font.pixelSize: 20
                                        color: root.activePopout === iconRect.modelData.id ? Theme.primaryColor : iMouse.containsMouse ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                                        rotation: iconRect.isGear && iMouse.containsMouse ? 90 : 0

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 200
                                            }

                                        }

                                        Behavior on rotation {
                                            NumberAnimation {
                                                duration: 500
                                                easing.type: Easing.OutCubic
                                            }

                                        }

                                    }

                                    MouseArea {
                                        id: iMouse

                                        anchors.fill: parent
                                        hoverEnabled: root.isPinned
                                        enabled: root.isPinned
                                        cursorShape: root.isPinned ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onEntered: {
                                            root.activePopout = iconRect.modelData.id;
                                        }
                                    }

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 300
                                            easing.type: Easing.OutCubic
                                        }

                                    }

                                }

                            }

                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }

                        }

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

                    }

                    Rectangle {
                        anchors.top: iconRow.bottom
                        anchors.horizontalCenter: iconRow.horizontalCenter
                        width: iconRow.width
                        height: 20
                        color: "transparent"

                        HoverHandler {
                            enabled: root.isPinned
                            onHoveredChanged: {
                                root.bridgeHovered = hovered;
                                if (!hovered)
                                    root.checkClose();

                            }
                        }

                    }

                    HoverHandler {
                        enabled: root.isPinned
                        onHoveredChanged: {
                            root.iconRowHovered = hovered;
                            if (!hovered)
                                root.checkClose();

                        }
                    }

                }

                DayWidget {
                    font.family: "CaskaydiaCove NF"
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

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
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

    }

    PopoutShape {
        id: nestedPopout

        property int lastActive: 1
        property bool isOpen: false
        property real targetW: 580
        property real targetH: 0
        property real targetX: 0
        property bool hasOpenedOnce: false
        property bool isAnimating: heightAnim.running || widthAnim.running || xAnim.running

        clip: true
        anchors.top: popout.bottom
        width: targetW
        height: targetH
        x: targetX
        alignment: 0
        radius: 15
        color: Theme.surfaceContainer
        visible: height > 1 || isAnimating
        onHeightChanged: {
            if (height > 0 && !isOpen && !heightAnim.running) {
                isOpen = true;
                hasOpenedOnce = true;
            }
            if (height === 0 && isOpen)
                isOpen = false;

        }

        HoverHandler {
            onHoveredChanged: {
                root.nestedHovered = hovered;
                if (!hovered)
                    root.checkClose();

            }
        }

        Item {
            anchors.fill: parent

            Repeater {
                model: root.popoutIcons

                Loader {
                    id: popoutLoader

                    required property var modelData
                    readonly property bool isAnilist: popoutLoader.modelData.id === 3

                    anchors.fill: parent
                    active: root.isPinned && (isAnilist ? true : root.activePopout === popoutLoader.modelData.id)
                    asynchronous: !isAnilist
                    opacity: root.activePopout === popoutLoader.modelData.id ? 1 : 0
                    visible: opacity > 0
                    sourceComponent: root.popoutComponents[popoutLoader.modelData.id]

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.InOutQuad
                        }

                    }

                }

            }

        }

        Behavior on width {
            id: widthBehavior

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
                onFinished: {
                    if (nestedPopout.height > 0)
                        nestedPopout.isOpen = true;
                    else
                        nestedPopout.isOpen = false;
                }
            }

        }

        Behavior on x {
            id: xBehavior

            NumberAnimation {
                id: xAnim

                duration: 300
                easing.type: Easing.InOutQuad
            }

        }

    }

    HoverHandler {
        onHoveredChanged: {
            root.isHovered = hovered;
            if (!hovered)
                root.hoveredWayland = null;

        }
    }

}
