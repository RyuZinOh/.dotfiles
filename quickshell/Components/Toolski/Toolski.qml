import QtQuick
import qs.Services.Theme

Item {
    id: root
    anchors.fill: parent
    property bool isHovered: false
    property bool isExpanded: false
    property int openedBladeIndex: -1

    Timer {
        id: autoHideTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            root.isHovered = false;
            root.isExpanded = false;
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 5
        height: parent.height
        hoverEnabled: true
        enabled: openedBladeIndex === -1
        onEntered: {
            root.isHovered = true;
            autoHideTimer.stop();
        }
        onExited: {
            if (!mainCircle.containsMouse && !root.isExpanded) {
                autoHideTimer.restart();
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
        property bool containsMouse: false
        property real ballX: root.isHovered ? 0 : -150

        transform: Translate {
            x: mainCircle.ballX
        }

        Behavior on ballX {
            SpringAnimation {
                spring: 2.5
                damping: 0.2
                epsilon: 0.01
                velocity: 1200
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

            scale: mainCircle.containsMouse ? 1.05 : 1.0

            Behavior on scale {
                SpringAnimation {
                    spring: 3.0
                    damping: 0.3
                    epsilon: 0.01
                }
            }

            Behavior on border.width {
                SpringAnimation {
                    spring: 3.0
                    damping: 0.3
                    epsilon: 0.01
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: ":3"
            color: Theme.onSurface
            font.pixelSize: 26
            font.family: "CaskaydiaCove NF"

            scale: mainCircle.containsMouse ? 1.1 : 1.0

            Behavior on scale {
                SpringAnimation {
                    spring: 3.0
                    damping: 0.3
                    epsilon: 0.01
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                mainCircle.containsMouse = true;
                autoHideTimer.stop();
            }
            onExited: {
                mainCircle.containsMouse = false;
                if (!root.isExpanded) {
                    autoHideTimer.restart();
                }
            }
            onClicked: {
                root.isExpanded = !root.isExpanded;
                if (root.isExpanded) {
                    autoHideTimer.stop();
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
            model: 4

            Rectangle {
                id: blade
                width: 120
                height: 40
                radius: 10
                color: Theme.surfaceContainer
                border.color: bladeMouseArea.containsMouse ? Theme.onSurface : Theme.outlineColor
                border.width: bladeMouseArea.containsMouse ? 2 : 1
                visible: (root.isExpanded || targetRotation !== 0 || targetX !== 0) && openedBladeIndex !== index

                transformOrigin: Item.Left
                x: 0
                y: bladesContainer.height / 2 - height / 2

                property real targetRotation: root.isExpanded ? (index - 1.5) * 20 : 0
                property real targetX: root.isExpanded ? 15 : 0
                property real hoverScale: bladeMouseArea.containsMouse ? 1.15 : 1.0

                rotation: targetRotation

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
                        epsilon: 0.01
                    }
                }

                Behavior on targetX {
                    SpringAnimation {
                        spring: 2.5
                        damping: 0.25
                        epsilon: 0.01
                    }
                }

                Behavior on hoverScale {
                    SpringAnimation {
                        spring: 3.5
                        damping: 0.25
                        epsilon: 0.01
                    }
                }

                Behavior on border.width {
                    SpringAnimation {
                        spring: 3.0
                        damping: 0.3
                        epsilon: 0.01
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: ["󰏘", "", "󱎓", "󱗻"][index]
                    color: Theme.onSurface
                    font.pixelSize: 20
                    font.family: "CaskaydiaCove NF"

                    scale: bladeMouseArea.containsMouse ? 1.2 : 1.0

                    Behavior on scale {
                        SpringAnimation {
                            spring: 3.5
                            damping: 0.3
                            epsilon: 0.01
                        }
                    }
                }

                MouseArea {
                    id: bladeMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    property bool containsMouse: false
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
                        }
                        blade.x = Qt.binding(() => startX);
                    }

                    onEntered: {
                        containsMouse = true;
                        autoHideTimer.stop();
                    }

                    onExited: {
                        containsMouse = false;
                    }
                }

                Behavior on x {
                    SpringAnimation {
                        spring: 3.0
                        damping: 0.3
                        epsilon: 0.01
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
        property real targetHeight: openedBladeIndex !== -1 ? 700 : 0

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
                epsilon: 0.01
            }
        }

        Behavior on targetWidth {
            SpringAnimation {
                spring: 2.0
                damping: 0.3
                epsilon: 0.01
            }
        }

        Behavior on targetHeight {
            SpringAnimation {
                spring: 2.0
                damping: 0.3
                epsilon: 0.01
            }
        }

        Item {
            anchors.fill: parent
            visible: fullScreenCard.width > 400

            scale: fullScreenCard.width > 400 ? 1.0 : 0.8

            Behavior on scale {
                SpringAnimation {
                    spring: 2.5
                    damping: 0.3
                    epsilon: 0.01
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Hello World\nBlade " + (openedBladeIndex + 1)
                color: Theme.onSurface
                font.pixelSize: 48
                font.family: "CaskaydiaCove NF"
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 20
                width: 40
                height: 40
                radius: 20
                color: Theme.surfaceContainerHighest
                border.color: Theme.outlineColor
                border.width: 1

                scale: closeMouseArea.containsMouse ? 1.15 : 1.0

                Behavior on scale {
                    SpringAnimation {
                        spring: 3.5
                        damping: 0.3
                        epsilon: 0.01
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: Theme.onSurface
                    font.pixelSize: 20

                    rotation: closeMouseArea.containsMouse ? 90 : 0

                    Behavior on rotation {
                        SpringAnimation {
                            spring: 3.0
                            damping: 0.3
                            epsilon: 0.01
                        }
                    }
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    property bool containsMouse: false

                    onEntered: containsMouse = true
                    onExited: containsMouse = false

                    onClicked: {
                        root.openedBladeIndex = -1;
                    }
                }
            }
        }
    }
}
