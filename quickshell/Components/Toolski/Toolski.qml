import QtQuick
import qs.Services.Theme
import qs.Components.Toolski.Nihongo
import qs.Components.Toolski.Powerski

Item {
    id: root
    anchors.fill: parent
    property bool isHovered: false
    property bool isExpanded: false
    property int openedBladeIndex: -1
    property real currentCardHeight: 700
    Timer {
        id: autoHideTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            if (!root.isExpanded) {
                root.isHovered = false;
                root.isExpanded = false;
            }
        }
    }

    Item {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 0.1
        height: 100
        visible: openedBladeIndex === -1

        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    root.isHovered = true;
                    autoHideTimer.stop();
                } else {
                    if (!root.isExpanded) {
                        autoHideTimer.restart();
                    }
                }
            }
        }
    }

    Item {
        id: mainCircle
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 60
        height: 60
        visible: ballX > -100

        property real ballX: root.isHovered ? 0 : -150
        property real shakeOffset: 0

        transform: [
            Translate {
                x: mainCircle.ballX + mainCircle.shakeOffset
            }
        ]

        Behavior on ballX {
            SpringAnimation {
                spring: 2.5
                damping: 0.2
                epsilon: 0.01
                velocity: 1200
            }
        }

        SequentialAnimation {
            id: shakeAnimation
            running: false

            NumberAnimation {
                target: mainCircle
                property: "shakeOffset"
                to: -10
                duration: 50
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: mainCircle
                property: "shakeOffset"
                to: 10
                duration: 100
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: mainCircle
                property: "shakeOffset"
                to: -10
                duration: 100
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: mainCircle
                property: "shakeOffset"
                to: 10
                duration: 100
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: mainCircle
                property: "shakeOffset"
                to: 0
                duration: 50
                easing.type: Easing.InQuad
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: width / 2
            color: Theme.surfaceContainer
            border.color: Theme.outlineColor
            border.width: 1

            scale: mainCircleHover.hovered ? 1.05 : 1.0

            Behavior on scale {
                SpringAnimation {
                    spring: 3.0
                    damping: 0.3
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: ":3"
            color: Theme.onSurface
            font.pixelSize: 26
            font.family: "CaskaydiaCove NF"
        }

        HoverHandler {
            id: mainCircleHover
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                if (hovered) {
                    root.isHovered = true;
                    autoHideTimer.stop();
                } else {
                    if (!root.isExpanded) {
                        autoHideTimer.restart();
                    }
                }
            }
        }

        TapHandler {
            onTapped: {
                if (root.openedBladeIndex !== -1) {
                    shakeAnimation.restart();
                } else {
                    root.isExpanded = !root.isExpanded;
                    if (root.isExpanded) {
                        autoHideTimer.stop();
                    } else {
                        autoHideTimer.restart();
                    }
                }
            }
        }
    }

    Item {
        id: bladesContainer
        anchors.left: mainCircle.right
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        width: 200
        height: 200
        visible: mainCircle.visible

        Repeater {
            model: [
                {
                    icon: "日本",
                    blade: 0,
                    cardHeight: 850
                },
                {
                    icon: "󰘳",
                    blade: 1,
                    cardHeight: 400
                },
                {
                    icon: "󱎓",
                    blade: 2,
                    cardHeight: 600
                },
                {
                    icon: "󱗻",
                    blade: 3,
                    cardHeight: 650
                }
            ]

            Rectangle {
                id: blade
                width: 120
                height: 40
                radius: 10
                color: Theme.surfaceContainer
                border.color: bladeHoverHandler.hovered ? Theme.onSurface : Theme.outlineColor
                border.width: bladeHoverHandler.hovered ? 2 : 1
                visible: (root.isExpanded || targetRotation !== 0) && openedBladeIndex !== index

                transformOrigin: Item.Left
                x: 0
                y: bladesContainer.height / 2 - height / 2

                property real targetRotation: root.isExpanded ? (index - 1.5) * 20 : 0
                property real targetX: root.isExpanded ? 15 : 0
                property real hoverScale: bladeHoverHandler.hovered ? 1.15 : 1.0

                rotation: targetRotation

                Behavior on hoverScale {
                    SpringAnimation {
                        spring: 3.5
                        damping: 0.3
                    }
                }

                transform: [
                    Translate {
                        x: blade.targetX
                    },
                    Scale {
                        origin.x: blade.width / 2
                        origin.y: blade.height / 2
                        xScale: blade.hoverScale
                        yScale: blade.hoverScale
                    }
                ]

                Behavior on targetRotation {
                    SpringAnimation {
                        spring: 2.5
                        damping: 0.25
                    }
                }

                Behavior on targetX {
                    SpringAnimation {
                        spring: 2.5
                        damping: 0.25
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: Theme.onSurface
                    font.pixelSize: 20
                    font.family: "CaskaydiaCove NF"
                }

                HoverHandler {
                    id: bladeHoverHandler
                    cursorShape: Qt.PointingHandCursor
                    onHoveredChanged: {
                        if (hovered) {
                            autoHideTimer.stop();
                        }
                    }
                }

                MouseArea {
                    id: bladeMouseArea
                    anchors.fill: parent
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                    property real startX: 0
                    property real dragStartX: 0

                    onPressed: mouse => {
                        startX = blade.x;
                        dragStartX = mouse.x;
                    }

                    onPositionChanged: mouse => {
                        if (pressed) {
                            var delta = mouse.x - dragStartX;
                            if (delta > 0) {
                                blade.x = startX + delta;
                            }
                        }
                    }

                    onReleased: mouse => {
                        var delta = mouse.x - dragStartX;
                        if (delta > 50) {
                            root.openedBladeIndex = index;
                            root.currentCardHeight = modelData.cardHeight;
                        }
                        blade.x = Qt.binding(() => startX);
                    }
                }

                Behavior on x {
                    SpringAnimation {
                        spring: 3.0
                        damping: 0.3
                    }
                }
            }
        }
    }

    Rectangle {
        id: fullScreenCard
        visible: openedBladeIndex !== -1

        property real targetX: openedBladeIndex !== -1 ? parent.width / 2 : (mainCircle.x + mainCircle.width + 5 + 60)
        property real targetY: parent.height / 2
        property real targetWidth: openedBladeIndex !== -1 ? 500 : 0
        property real targetHeight: openedBladeIndex !== -1 ? root.currentCardHeight : 0

        x: targetX - width / 2
        y: targetY - height / 2
        width: targetWidth
        height: targetHeight

        radius: 20
        color: Theme.surfaceContainer
        border.color: Theme.outlineColor
        border.width: 2

        Behavior on targetX {
            SpringAnimation {
                spring: 2.0
                damping: 0.3
            }
        }
        Behavior on targetWidth {
            SpringAnimation {
                spring: 2.0
                damping: 0.3
            }
        }
        Behavior on targetHeight {
            SpringAnimation {
                spring: 2.0
                damping: 0.3
            }
        }

        Rectangle {
            id: closeButton
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 20
            width: 40
            height: 40
            radius: 20
            color: Theme.surfaceContainerHighest
            border.color: Theme.outlineColor
            border.width: 1
            z: 100

            scale: closeHoverHandler.hovered ? 1.15 : 1.0

            Behavior on scale {
                SpringAnimation {
                    spring: 3.5
                    damping: 0.3
                }
            }

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: Theme.onSurface
                font.pixelSize: 20

                rotation: closeHoverHandler.hovered ? 90 : 0

                Behavior on rotation {
                    SpringAnimation {
                        spring: 3.0
                        damping: 0.3
                    }
                }
            }

            HoverHandler {
                id: closeHoverHandler
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.openedBladeIndex = -1
            }
        }

        Nihongo {
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 70
            visible: openedBladeIndex === 0 && fullScreenCard.width > 400
        }
        Powerski {
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 70
            visible: openedBladeIndex === 1 && fullScreenCard.width > 400
        }
    }
}
