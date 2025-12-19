import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import QtMultimedia

Item {
    id: root

    property bool active: false

    Loader {
        id: omnitrixLoader
        active: root.active
        anchors.centerIn: parent

        sourceComponent: Rectangle {
            id: omnitrixRoot
            implicitWidth: 400
            implicitHeight: 400
            color: "transparent"

            MediaPlayer {
                id: morphSound
                source: "../../Assets/in.mp3"
                audioOutput: AudioOutput {}
                playbackRate: 1.5
            }

            MediaPlayer {
                id: switchSound
                source: "../../Assets/switch.mp3"
                audioOutput: AudioOutput {}
                playbackRate: 2.0
            }

            MediaPlayer {
                id: transformSound
                source: "../../Assets/transform.mp3"
                audioOutput: AudioOutput {}
                playbackRate: 2.5
            }

            Item {
                id: omnitrix
                implicitWidth: 500
                implicitHeight: 500
                anchors.centerIn: parent

                property real morphProgress: 0
                property real ringRotation: 0
                property int currentAlienIndex: 0
                property var alienList: ["A", "B", "C", "D"]
                property bool isTransformed: false
                property bool isTransforming: false
                property real flashProgress: 0

                NumberAnimation on morphProgress {
                    id: morphAnim
                    duration: 300
                    easing.type: Easing.OutCubic
                    running: false
                    onFinished: {
                        if (omnitrix.morphProgress === 1) {
                            omnitrix.isTransformed = true;
                        }
                    }
                }

                NumberAnimation on morphProgress {
                    id: reverseAnim
                    duration: 300
                    easing.type: Easing.OutCubic
                    running: false
                    onFinished: {
                        if (omnitrix.morphProgress === 0) {
                            omnitrix.isTransformed = false;
                            omnitrix.isTransforming = false;
                        }
                    }
                }

                SequentialAnimation {
                    id: transformFlashAnim

                    ScriptAction {
                        script: {
                            omnitrix.isTransforming = true;
                        }
                    }

                    NumberAnimation {
                        target: omnitrix
                        property: "flashProgress"
                        from: 0
                        to: 1
                        duration: 200
                        easing.type: Easing.OutQuad
                    }

                    PauseAnimation {
                        duration: 150
                    }

                    ParallelAnimation {
                        NumberAnimation {
                            target: omnitrix
                            property: "flashProgress"
                            to: 0
                            duration: 300
                            easing.type: Easing.InQuad
                        }

                        NumberAnimation {
                            target: omnitrix
                            property: "morphProgress"
                            to: 0
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }

                    ScriptAction {
                        script: {
                            omnitrix.isTransformed = false;
                            omnitrix.isTransforming = false;
                        }
                    }
                }

                Item {
                    id: outerRing
                    anchors.fill: parent
                    rotation: omnitrix.ringRotation

                    Behavior on rotation {
                        RotationAnimation {
                            duration: 150
                            direction: RotationAnimation.Shortest
                            easing.type: Easing.OutQuad
                        }
                    }

                    Repeater {
                        model: 4
                        Item {
                            x: omnitrix.width / 2 + Math.cos((index * 90 - 90) * Math.PI / 180) * 230 - 30
                            y: omnitrix.height / 2 + Math.sin((index * 90 - 90) * Math.PI / 180) * 230 - 12.5
                            width: 60
                            height: 25
                            rotation: index * 90

                            Rectangle {
                                anchors.fill: parent
                                color: "#2d2d2d"
                                radius: 5
                                antialiasing: true
                                smooth: true
                                border.color: "#1a1a1a"
                                border.width: 2
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 3
                                color: "#00ff00"
                                radius: 3
                                antialiasing: true
                                smooth: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: omnitrix.morphProgress === 1 ? Qt.OpenHandCursor : Qt.ArrowCursor
                        enabled: omnitrix.morphProgress === 1

                        property real lastAngle: 0
                        property bool isDragging: false

                        onPressed: {
                            if (omnitrix.morphProgress === 1) {
                                isDragging = true;
                                var centerX = omnitrix.width / 2;
                                var centerY = omnitrix.height / 2;
                                lastAngle = Math.atan2(mouseY - centerY, mouseX - centerX) * 180 / Math.PI;
                                cursorShape = Qt.ClosedHandCursor;
                            }
                        }

                        onPositionChanged: {
                            if (isDragging && omnitrix.morphProgress === 1) {
                                var centerX = omnitrix.width / 2;
                                var centerY = omnitrix.height / 2;
                                var currentAngle = Math.atan2(mouseY - centerY, mouseX - centerX) * 180 / Math.PI;
                                var deltaAngle = currentAngle - lastAngle;

                                if (deltaAngle > 180) {
                                    deltaAngle -= 360;
                                }
                                if (deltaAngle < -180) {
                                    deltaAngle += 360;
                                }

                                omnitrix.ringRotation += deltaAngle;
                                lastAngle = currentAngle;

                                var normalizedRotation = ((omnitrix.ringRotation % 360) + 360) % 360;
                                var newIndex = Math.round(normalizedRotation / 90) % 4;

                                if (newIndex !== omnitrix.currentAlienIndex) {
                                    switchSound.play();
                                    omnitrix.currentAlienIndex = newIndex;
                                }
                            }
                        }

                        onReleased: {
                            isDragging = false;
                            if (omnitrix.morphProgress === 1) {
                                cursorShape = Qt.OpenHandCursor;
                            }
                        }
                    }
                }

                Rectangle {
                    id: outerCircle
                    implicitWidth: 430
                    implicitHeight: 430
                    radius: width / 2
                    color: "#4a4a4a"
                    anchors.centerIn: parent
                    antialiasing: true
                    smooth: true
                    border.color: "#5a5a5a"
                    border.width: 1
                }

                Rectangle {
                    id: blackRing
                    implicitWidth: 420
                    implicitHeight: 420
                    radius: width / 2
                    color: "#0d0d0d"
                    anchors.centerIn: parent
                    antialiasing: true
                    smooth: true
                    border.color: "#1a1a1a"
                    border.width: 1
                }

                Rectangle {
                    id: innerGrayCircle
                    implicitWidth: 400
                    implicitHeight: 400
                    radius: width / 2
                    color: "#5a5a5a"
                    anchors.centerIn: parent
                    antialiasing: true
                    smooth: true
                    border.color: "#6a6a6a"
                    border.width: 1
                }

                Item {
                    id: centerFaceContainer
                    implicitWidth: 360
                    implicitHeight: 360
                    anchors.centerIn: parent

                    Rectangle {
                        id: centerFace
                        anchors.fill: parent
                        radius: width / 2
                        color: "#00ff00"
                        anchors.centerIn: parent
                        antialiasing: true
                        smooth: true

                        Rectangle {
                            id: innerGreenRect
                            anchors.fill: parent
                            anchors.margins: 5
                            radius: width / 2
                            color: "#a8ff00"
                            antialiasing: true
                            smooth: true

                            Item {
                                id: hourglassContainer
                                anchors.fill: parent
                                anchors.margins: 0
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: innerGreenRect.width
                                        height: innerGreenRect.height
                                        radius: width / 2
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onEntered: {
                                        if (!omnitrix.isTransformed) {
                                            morphSound.play();
                                            morphAnim.to = 1;
                                            morphAnim.restart();
                                        }
                                    }

                                    // not reverting for now
                                    onExited: {}
                                }

                                // Green flash overlay for entire container
                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: "#00ff00"
                                    opacity: omnitrix.flashProgress * 0.95
                                    visible: omnitrix.isTransforming
                                    z: 10
                                }

                                Shape {
                                    id: leftTriangle
                                    anchors.fill: parent
                                    antialiasing: true
                                    smooth: true

                                    transform: [
                                        Translate {
                                            x: (omnitrix.morphProgress * hourglassContainer.width / 2)
                                        },
                                        Scale {
                                            origin.x: hourglassContainer.width / 2
                                            origin.y: hourglassContainer.height / 2
                                            xScale: 1 + (omnitrix.morphProgress * 0.05)
                                            yScale: 1 + (omnitrix.morphProgress * 0.05)
                                        }
                                    ]

                                    ShapePath {
                                        fillColor: "#1a1a1a"
                                        strokeColor: "transparent"

                                        startX: 0
                                        startY: 0
                                        PathLine {
                                            x: hourglassContainer.width / 2
                                            y: hourglassContainer.height / 2
                                        }
                                        PathLine {
                                            x: 0
                                            y: hourglassContainer.height
                                        }
                                        PathLine {
                                            x: 0
                                            y: 0
                                        }
                                    }
                                }

                                Shape {
                                    id: rightTriangle
                                    anchors.fill: parent
                                    antialiasing: true
                                    smooth: true

                                    transform: [
                                        Translate {
                                            x: -(omnitrix.morphProgress * hourglassContainer.width / 2)
                                        },
                                        Scale {
                                            origin.x: hourglassContainer.width / 2
                                            origin.y: hourglassContainer.height / 2
                                            xScale: 1 + (omnitrix.morphProgress * 0.05)
                                            yScale: 1 + (omnitrix.morphProgress * 0.05)
                                        }
                                    ]

                                    ShapePath {
                                        fillColor: "#1a1a1a"
                                        strokeColor: "transparent"

                                        startX: hourglassContainer.width
                                        startY: 0
                                        PathLine {
                                            x: hourglassContainer.width / 2
                                            y: hourglassContainer.height / 2
                                        }
                                        PathLine {
                                            x: hourglassContainer.width
                                            y: hourglassContainer.height
                                        }
                                        PathLine {
                                            x: hourglassContainer.width
                                            y: 0
                                        }
                                    }
                                }

                                Text {
                                    id: alienText
                                    text: omnitrix.alienList[omnitrix.currentAlienIndex]
                                    color: omnitrix.isTransforming ? "#ffffff" : "#00ff00"
                                    font.pixelSize: omnitrix.isTransforming ? 180 : 130
                                    font.bold: true
                                    anchors.centerIn: parent
                                    opacity: omnitrix.morphProgress
                                    z: 12

                                    Behavior on font.pixelSize {
                                        NumberAnimation {
                                            duration: 150
                                            easing.type: Easing.OutBack
                                        }
                                    }

                                    // Intense glow effect when transforming
                                    layer.enabled: omnitrix.isTransforming
                                    layer.effect: Glow {
                                        samples: 32
                                        color: "#00ff00"
                                        spread: 0.8
                                        radius: 24
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: omnitrix.isTransformed && !omnitrix.isTransforming

                                        onClicked: {
                                            if (omnitrix.isTransformed && !omnitrix.isTransforming) {
                                                transformSound.play();
                                                transformFlashAnim.restart();
                                            }
                                        }
                                    }

                                    Behavior on text {
                                        SequentialAnimation {
                                            NumberAnimation {
                                                target: alienText
                                                property: "opacity"
                                                to: 0
                                                duration: 100
                                            }
                                            PropertyAction {
                                                target: alienText
                                                property: "text"
                                            }
                                            NumberAnimation {
                                                target: alienText
                                                property: "opacity"
                                                to: omnitrix.morphProgress
                                                duration: 100
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
