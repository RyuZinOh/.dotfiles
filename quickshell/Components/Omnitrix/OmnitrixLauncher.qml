import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import QtMultimedia
import Quickshell.Io

Item {
    id: root
    property bool active: false

    readonly property color outerRingSlotBg: "#000000"
    readonly property color outerRingSlotBorder: "#000000"
    readonly property color outerRingSlotFill: "#00ff00"

    readonly property color watchBodyOuter: "#4a4a4a"
    readonly property color watchBodyOuterBorder: "#5a5a5a"
    readonly property color watchBodyMiddle: "#0d0d0d"
    readonly property color watchBodyMiddleBorder: "#1a1a1a"
    readonly property color watchBodyInner: "#5a5a5a"
    readonly property color watchBodyInnerBorder: "#6a6a6a"

    readonly property color centerRingColor: "#00ff00"
    readonly property color centerBgColor: "#000000"
    readonly property color hourglassTriangle: "#00ff00"
    readonly property color diamondBg: "#00ff00"
    readonly property color flashColor: "#a8ff00"

    Loader {
        id: omnitrixLoader
        active: root.active
        anchors.centerIn: parent

        sourceComponent: Rectangle {
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

            Process {
                id: copyPfpProcess
            }

            Process {
                id: notifyProcess
            }

            Item {
                id: omnitrix
                implicitWidth: 500
                implicitHeight: 500
                anchors.centerIn: parent

                property real morphProgress: 0
                property real ringRotation: 0
                property int currentAlienIndex: 0
                // shilouette [these arent ready yet visually]
                property var silhouetteList: ["file:///home/safal726/pfps/shilouette/reddo.png", "file:///home/safal726/pfps/shilouette/gingka.png", "file:///home/safal726/pfps/shilouette/free.png", "file:///home/safal726/pfps/shilouette/ichigo.png", "file:///home/safal726/pfps/shilouette/joshua.png", "file:///home/safal726/pfps/shilouette/lionheart.png", "file:///home/safal726/pfps/shilouette/Meitenkun.png", "file:///home/safal726/pfps/shilouette/nura_again.png", "file:///home/safal726/pfps/shilouette/nura_again_.png", "file:///home/safal726/pfps/shilouette/nura_yokai.png", "file:///home/safal726/pfps/shilouette/woo.png"]
                // mapped to real image
                property var realImageList: ["file:///home/safal726/pfps/reddo.jpeg", "file:///home/safal726/pfps/gingka.jpeg", "file:///home/safal726/pfps/free.jpg", "file:///home/safal726/pfps/ichigo.jpg", "file:///home/safal726/pfps/joshua.jpeg", "file:///home/safal726/pfps/lioheart.jpeg", "file:///home/safal726/pfps/Meitenkun.jpg", "file:///home/safal726/pfps/nura_again.jpg", "file:///home/safal726/pfps/nura_again_.jpg", "file:///home/safal726/pfps/nura_yokai.jpg", "file:///home/safal726/pfps/woo.jpeg"]
                property bool isTransformed: false
                property bool isTransforming: false
                property real flashProgress: 0

                function getImageNameWithoutExtension(filePath) {
                    const path = filePath.toString().replace("file://", "");
                    const fileName = path.split('/').pop();
                    return fileName.replace(/\.[^/.]+$/, "");
                }

                function copyCurrentImageToCache() {
                    const sourceFile = realImageList[currentAlienIndex];
                    const sourcePath = sourceFile.toString().replace("file://", "");
                    const dest = "/home/safal726/.cache/safalQuick/pfp.jpeg";
                    const imageName = getImageNameWithoutExtension(sourceFile);

                    copyPfpProcess.command = ["/usr/bin/sh", "-c", `cp "${sourcePath}" "${dest}"`];
                    copyPfpProcess.running = true;

                    notifyProcess.command = ["notify-send", "-a", "Azmuth", "-i", "/home/safal726/pfps/azmuth.svg", "Lockscreen Applied", imageName];
                    notifyProcess.running = true;
                }

                NumberAnimation on morphProgress {
                    id: morphAnim
                    duration: 400
                    easing.type: Easing.OutCubic
                    running: false
                    onFinished: {
                        if (omnitrix.morphProgress === 1) {
                            omnitrix.isTransformed = true;
                        }
                    }
                }

                SequentialAnimation {
                    id: transformFlashAnim

                    ScriptAction {
                        script: {
                            omnitrix.isTransforming = true;
                            omnitrix.copyCurrentImageToCache();
                        }
                    }

                    NumberAnimation {
                        target: omnitrix
                        property: "flashProgress"
                        from: 0
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuad
                    }

                    PauseAnimation {
                        duration: 200
                    }

                    ParallelAnimation {
                        NumberAnimation {
                            target: omnitrix
                            property: "flashProgress"
                            to: 0
                            duration: 600
                            easing.type: Easing.InOutQuad
                        }

                        NumberAnimation {
                            target: omnitrix
                            property: "morphProgress"
                            to: 0
                            duration: 600
                            easing.type: Easing.InOutCubic
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
                            duration: 200
                            direction: RotationAnimation.Shortest
                            easing.type: Easing.OutCubic
                        }
                    }

                    Repeater {
                        model: 4
                        delegate: Item {
                            x: omnitrix.width / 2 + Math.cos((index * 90 - 90) * Math.PI / 180) * 230 - 30
                            y: omnitrix.height / 2 + Math.sin((index * 90 - 90) * Math.PI / 180) * 230 - 12.5
                            width: 60
                            height: 25
                            rotation: index * 90

                            Rectangle {
                                anchors.fill: parent
                                color: root.outerRingSlotBg
                                radius: 5
                                border.color: root.outerRingSlotBorder
                                border.width: 2
                                antialiasing: true

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 3
                                    color: root.outerRingSlotFill
                                    radius: 3
                                    antialiasing: true
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: omnitrix.morphProgress === 1 ? Qt.OpenHandCursor : Qt.ArrowCursor
                        enabled: omnitrix.morphProgress === 1

                        property real lastAngle: 0
                        property bool isDragging: false

                        onPressed: mouse => {
                            if (omnitrix.morphProgress === 1) {
                                isDragging = true;
                                const centerX = omnitrix.width / 2;
                                const centerY = omnitrix.height / 2;
                                lastAngle = Math.atan2(mouseY - centerY, mouseX - centerX) * 180 / Math.PI;
                                cursorShape = Qt.ClosedHandCursor;
                            }
                        }

                        onPositionChanged: mouse => {
                            if (isDragging && omnitrix.morphProgress === 1) {
                                const centerX = omnitrix.width / 2;
                                const centerY = omnitrix.height / 2;
                                let currentAngle = Math.atan2(mouseY - centerY, mouseX - centerX) * 180 / Math.PI;
                                let deltaAngle = currentAngle - lastAngle;

                                if (deltaAngle > 180) {
                                    deltaAngle -= 360;
                                }
                                if (deltaAngle < -180) {
                                    deltaAngle += 360;
                                }

                                omnitrix.ringRotation += deltaAngle;
                                lastAngle = currentAngle;

                                const normalizedRotation = ((omnitrix.ringRotation % 360) + 360) % 360;
                                const totalImages = omnitrix.silhouetteList.length;
                                const anglePerImage = 360 / totalImages;
                                const newIndex = Math.round(normalizedRotation / anglePerImage) % totalImages;

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
                    implicitWidth: 430
                    implicitHeight: 430
                    radius: width / 2
                    color: root.watchBodyOuter
                    border.color: root.watchBodyOuterBorder
                    border.width: 1
                    anchors.centerIn: parent
                    antialiasing: true
                }

                Rectangle {
                    implicitWidth: 420
                    implicitHeight: 420
                    radius: width / 2
                    color: root.watchBodyMiddle
                    border.color: root.watchBodyMiddleBorder
                    border.width: 1
                    anchors.centerIn: parent
                    antialiasing: true
                }

                Rectangle {
                    implicitWidth: 400
                    implicitHeight: 400
                    radius: width / 2
                    color: root.watchBodyInner
                    border.color: root.watchBodyInnerBorder
                    border.width: 1
                    anchors.centerIn: parent
                    antialiasing: true
                }

                Item {
                    implicitWidth: 360
                    implicitHeight: 360
                    anchors.centerIn: parent

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: root.centerRingColor
                        antialiasing: true

                        Rectangle {
                            id: innerGreenRect
                            anchors.fill: parent
                            anchors.margins: 5
                            radius: width / 2
                            color: root.centerBgColor
                            antialiasing: true

                            Item {
                                id: hourglassContainer
                                anchors.fill: parent
                                layer.enabled: true
                                layer.smooth: true
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
                                    color: root.flashColor
                                    opacity: omnitrix.flashProgress * 0.95
                                    visible: omnitrix.isTransforming
                                    z: 10
                                    antialiasing: true
                                }

                                Shape {
                                    anchors.fill: parent
                                    antialiasing: true
                                    smooth: true
                                    transform: [
                                        Translate {
                                            x: omnitrix.morphProgress * hourglassContainer.width / 2
                                        },
                                        Scale {
                                            origin.x: hourglassContainer.width / 2
                                            origin.y: hourglassContainer.height / 2
                                            xScale: 1 + (omnitrix.morphProgress * 0.05)
                                            yScale: 1 + (omnitrix.morphProgress * 0.05)
                                        }
                                    ]

                                    ShapePath {
                                        fillColor: root.hourglassTriangle
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
                                    anchors.fill: parent
                                    antialiasing: true
                                    smooth: true
                                    transform: [
                                        Translate {
                                            x: -omnitrix.morphProgress * hourglassContainer.width / 2
                                        },
                                        Scale {
                                            origin.x: hourglassContainer.width / 2
                                            origin.y: hourglassContainer.height / 2
                                            xScale: 1 + (omnitrix.morphProgress * 0.05)
                                            yScale: 1 + (omnitrix.morphProgress * 0.05)
                                        }
                                    ]

                                    ShapePath {
                                        fillColor: root.hourglassTriangle
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

                                Item {
                                    id: imageContainer
                                    anchors.centerIn: parent
                                    width: parent.width * 0.8 * omnitrix.morphProgress
                                    height: parent.height * 0.8 * omnitrix.morphProgress
                                    rotation: 45
                                    opacity: omnitrix.morphProgress
                                    z: 12

                                    scale: omnitrix.isTransforming ? 1.8 : 1
                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 500
                                            easing.type: Easing.OutBack
                                            easing.overshoot: 1.3
                                        }
                                    }

                                    Rectangle {
                                        id: diamondRect
                                        anchors.fill: parent
                                        color: root.diamondBg
                                        antialiasing: true

                                        Item {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            clip: true

                                            Image {
                                                anchors.centerIn: parent
                                                width: parent.width * 1.5
                                                height: parent.height * 1.5
                                                source: omnitrix.silhouetteList[omnitrix.currentAlienIndex]
                                                fillMode: Image.PreserveAspectCrop
                                                rotation: -45
                                                asynchronous: true
                                                smooth: true
                                            }
                                        }
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
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
