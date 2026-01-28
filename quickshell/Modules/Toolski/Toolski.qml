pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import "./Nihongo/"
import "./War"
import "./Wow/"

Item {
    id: root
    anchors.fill: parent
    property bool isHovered: false
    property bool isExpanded: false
    property int openedBladeIndex: -1
    property real currentCardHeight: 700
    property real currentCardWidth: 500
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
        visible: root.openedBladeIndex === -1

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
                    cardHeight: 850,
                    cardWidth: 500
                },
                {
                    icon: "󱎓",
                    blade: 2,
                    cardHeight: 420,
                    cardWidth: 450
                },
                {
                    icon: "󱗻",
                    blade: 3,
                    cardHeight: 400,
                    cardWidth: 1440
                }
            ]

            Rectangle {
                id: blade
                required property int index
                required property var modelData

                width: 120
                height: 40
                radius: 10
                color: Theme.surfaceContainer
                border.color: bladeHoverHandler.hovered ? Theme.onSurface : Theme.outlineColor
                border.width: bladeHoverHandler.hovered ? 2 : 1
                visible: (root.isExpanded || targetRotation !== 0) && root.openedBladeIndex !== blade.index

                transformOrigin: Item.Left
                x: 0
                y: bladesContainer.height / 2 - height / 2

                property real targetRotation: root.isExpanded ? (blade.index - 1.5) * 20 : 0
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
                    text: blade.modelData.icon
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
                        bladeMouseArea.startX = blade.x;
                        bladeMouseArea.dragStartX = mouse.x;
                    }

                    onPositionChanged: mouse => {
                        if (pressed) {
                            var delta = mouse.x - bladeMouseArea.dragStartX;
                            if (delta > 0) {
                                blade.x = bladeMouseArea.startX + delta;
                            }
                        }
                    }

                    onReleased: mouse => {
                        var delta = mouse.x - bladeMouseArea.dragStartX;
                        if (delta > 50) {
                            root.openedBladeIndex = blade.index;
                            root.currentCardHeight = blade.modelData.cardHeight;
                            root.currentCardWidth = blade.modelData.cardWidth;
                        }
                        blade.x = Qt.binding(() => bladeMouseArea.startX);
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

    Item {
        id: fullScreenCard
        visible: root.openedBladeIndex !== -1
        clip: true
        focus: visible

        property real dragOffsetY: 0
        property real dragRotation: 0
        property bool isFalling: false

        property real targetX: root.openedBladeIndex !== -1 ? root.parent.width / 2 : (mainCircle.x + mainCircle.width + 5 + 60)
        property real targetY: root.parent.height / 2
        property real targetWidth: root.openedBladeIndex !== -1 ? root.currentCardWidth : 0
        property real targetHeight: root.openedBladeIndex !== -1 ? root.currentCardHeight : 0

        x: targetX - targetWidth / 2
        y: targetY - targetHeight / 2 + dragOffsetY
        width: targetWidth
        height: targetHeight
        rotation: dragRotation

        Behavior on targetX {
            enabled: !fullScreenCard.isFalling
            SpringAnimation {
                spring: 2.0
                damping: 0.3
            }
        }
        Behavior on targetWidth {
            enabled: !fullScreenCard.isFalling
            SpringAnimation {
                spring: 2.0
                damping: 0.3
            }
        }
        Behavior on targetHeight {
            enabled: !fullScreenCard.isFalling
            SpringAnimation {
                spring: 2.0
                damping: 0.3
            }
        }

        Keys.onEscapePressed: {
            fullScreenCard.isFalling = true;
            gravityAnimation.restart();
        }

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: Theme.surfaceContainer
            border.color: Theme.outlineColor
            border.width: 2

            Loader {
                id: cardLoader
                anchors.fill: parent
                anchors.margins: 20
                active: root.openedBladeIndex !== -1 && fullScreenCard.width > 400
                asynchronous: true

                sourceComponent: {
                    switch (root.openedBladeIndex) {
                    case 0:
                        return nihongoComponent;
                    case 1:
                        return warComponent;
                    case 2:
                        return wowComponent;
                    default:
                        return null;
                    }
                }

                // onStatusChanged: {
                //     if (status === Loader.Loading) {
                //         console.log("Loading component...");
                //     } else if (status === Loader.Ready) {
                //         console.log("Component loaded and ready");
                //     }
                // }
            }

            Component {
                id: nihongoComponent
                Nihongo {}
            }

            Component {
                id: warComponent
                War {}
            }

            Component {
                id: wowComponent
                Wow {}
            }
        }

        ParallelAnimation {
            id: gravityAnimation

            NumberAnimation {
                target: fullScreenCard
                property: "dragOffsetY"
                to: root.height * 1.5
                duration: 1200
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: fullScreenCard
                property: "dragRotation"
                from: 0
                to: 95
                duration: 1200
                easing.type: Easing.Linear
            }

            onFinished: {
                root.openedBladeIndex = -1;
                fullScreenCard.isFalling = false;
                fullScreenCard.dragOffsetY = 0;
                fullScreenCard.dragRotation = 0;
            }
        }
    }
}
