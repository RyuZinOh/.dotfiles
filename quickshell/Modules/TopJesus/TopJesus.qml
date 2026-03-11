pragma ComponentBehavior: Bound
import QtQuick
// import Qt5Compat.GraphicalEffects
import qs.Services.Shapes
import qs.Services.Theme
import qs.Components.topjesus
/*I dont want to use qs for importing in modules for some weird reasons, well*/
import "./Callgorl/"
import "./MAL/"
import "./Powerski/"
import "./ControlRoom/"
import "./Wset/"

Item {
    id: root
    required property var parentScreen
    implicitWidth: 1440
    implicitHeight: popout.height + nestedPopout.height
    width: implicitWidth
    height: implicitHeight

    property bool isHovered: false
    property bool isPinned: false
    property int activePopout: 0

    onActivePopoutChanged: {
        if (root.activePopout > 0) {
            nestedPopout.lastActive = root.activePopout;
        }
    }

    readonly property var popoutIcons: [
        {
            id: 1,
            icon: "\udb81\udfea",
            xOff: 75,
            w: 580,
            h: 180
        },
        {
            id: 2,
            icon: "\uefa7",
            xOff: 200,
            w: 380,
            h: 250
        },
        {
            id: 3,
            icon: "\uee34",
            xOff: 200,
            w: 420,
            h: 280
        },
        {
            id: 4,
            icon: "\uee82",
            xOff: 225,
            w: 350,
            h: 140
        },
        {
            id: 5,
            icon: "\udb81\udce0",
            xOff: 200,
            w: 260,
            h: 230
        },
    ]

    readonly property var popoutComponents: [null, controlRoomComp, wsetComp, anilistComp, powerskiComp, callgorlComp]

    Component {
        id: controlRoomComp
        ControlRoom {}
    }
    Component {
        id: wsetComp
        Wset {}
    }
    Component {
        id: anilistComp
        Anilist {}
    }
    Component {
        id: powerskiComp
        Powerski {}
    }
    Component {
        id: callgorlComp
        Callgorl {}
    }

    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        hoverEnabled: true
        onEntered: root.isHovered = true
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
        height: (root.isHovered || root.isPinned) ? 40 : 0

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
            opacity: (root.isHovered || root.isPinned) ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

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
                BongoCat {
                    size: 64
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: pinArea.containsMouse ? Theme.surfaceBright : "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

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
                }

                Battery {
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

                            Repeater {
                                model: root.popoutIcons
                                Rectangle {
                                    id: iconRect
                                    required property var modelData
                                    width: 36
                                    height: 28
                                    radius: 6
                                    color: "transparent"
                                    readonly property bool isGear: iconRect.modelData.id === 2

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
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: root.activePopout = iconRect.modelData.id
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.top: iconRow.bottom
                        anchors.horizontalCenter: iconRow.horizontalCenter
                        width: iconRow.width
                        height: 10
                        color: "transparent"
                        visible: root.activePopout > 0
                        HoverHandler {
                            onHoveredChanged: hovered ? hoverTimer.stop() : hoverTimer.restart()
                        }
                    }
                    HoverHandler {
                        onHoveredChanged: hovered ? hoverTimer.stop() : hoverTimer.restart()
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
        onTriggered: root.activePopout = 0
    }

    PopoutShape {
        id: nestedPopout
        anchors.top: popout.bottom

        property int lastActive: 1
        property bool isAnimating: widthAnim.running || heightAnim.running

        // resolved cfg from predefined dims in popoutIcons
        readonly property var cfg: root.popoutIcons.find(p => p.id === (root.activePopout > 0 ? root.activePopout : lastActive)) ?? root.popoutIcons[0]

        width: cfg.w
        height: root.activePopout > 0 ? cfg.h : 0
        x: parent.width - cfg.w - cfg.xOff
        alignment: 0
        radius: 20
        color: Theme.surfaceContainer
        visible: height > 1 || isAnimating

        Behavior on width {
            enabled: root.activePopout > 0
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
            enabled: root.activePopout > 0
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        HoverHandler {
            onHoveredChanged: hovered ? hoverTimer.stop() : hoverTimer.restart()
        }

        Item {
            anchors.fill: parent
            Repeater {
                model: root.popoutIcons
                Loader {
                    id: popoutLoader
                    required property var modelData
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    active: popoutLoader.modelData.id === 3 ? true : root.activePopout === popoutLoader.modelData.id
                    asynchronous: popoutLoader.modelData.id !== 3
                    opacity: root.activePopout === popoutLoader.modelData.id ? 1 : 0
                    visible: opacity > 0
                    sourceComponent: root.popoutComponents[popoutLoader.modelData.id]
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            root.isHovered = hovered;
            if (!hovered)
                root.activePopout = 0;
        }
    }
}
