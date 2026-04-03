import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import QtMultimedia
import QtQuick
import QtQuick.Shapes
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
    readonly property color centerRingColor: "#000000"
    readonly property color centerBgColor: "#00ff00"
    readonly property color hourglassTriangle: "#000000"
    readonly property color diamondBg: "#00ff00"
    readonly property color flashColor: "#a8ff00"
    readonly property string pfpsPath: "file:///home/safalski/pfps/"

    Loader {
        id: omnitrixLoader

        active: root.active
        anchors.centerIn: parent

        sourceComponent: Rectangle {
            implicitWidth: 400
            implicitHeight: 400
            color: "transparent"

            FolderListModel {
                id: pfpModel

                folder: root.pfpsPath
                nameFilters: ["*.jpg", "*.jpeg", "*.png"]
                showDirs: false
            }

            SoundPlayer {
                id: morphSound

                source: "../../Assets/in.mp3"
                playbackRate: 1.5
            }

            SoundPlayer {
                id: switchSound

                source: "../../Assets/switch.mp3"
                playbackRate: 2
            }

            SoundPlayer {
                id: transformSound

                source: "../../Assets/transform.mp3"
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

                property real morphProgress: 0
                property real ringRotation: 0
                property int currentIndex: 0
                property bool isTransformed: false
                property bool isTransforming: false
                property real flashProgress: 0

                function currentFilePath() {
                    return pfpModel.get(currentIndex, "filePath") ?? "";
                }

                function currentFileName() {
                    return currentFilePath().split('/').pop().replace(/\.[^/.]+$/, "");
                }

                function copyToCache() {
                    copyPfpProcess.command = ["/usr/bin/sh", "-c", `cp "${currentFilePath().replace("file://", "")}" "/home/safalski/.cache/safalQuick/pfp.jpeg"`];
                    copyPfpProcess.running = true;
                    notifyProcess.command = ["notify-send", "-a", "Azmuth", "-i", "/home/safalski/pfps/azmuth.svg", "Lockscreen Applied", currentFileName()];
                    notifyProcess.running = true;
                }

                implicitWidth: 500
                implicitHeight: 500
                anchors.centerIn: parent

                SequentialAnimation {
                    id: transformFlashAnim

                    ScriptAction {
                        script: {
                            omnitrix.isTransforming = true;
                            omnitrix.copyToCache();
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
                                antialiasing: true

                                border {
                                    color: root.outerRingSlotBorder
                                    width: 2
                                }

                                Rectangle {
                                    color: root.outerRingSlotFill
                                    radius: 3
                                    antialiasing: true

                                    anchors {
                                        fill: parent
                                        margins: 3
                                    }

                                }

                            }

                        }

                    }

                    MouseArea {
                        property real lastAngle: 0
                        property bool isDragging: false

                        anchors.fill: parent
                        cursorShape: omnitrix.morphProgress === 1 ? Qt.OpenHandCursor : Qt.ArrowCursor
                        enabled: omnitrix.morphProgress === 1
                        onPressed: (mouse) => {
                            isDragging = true;
                            cursorShape = Qt.ClosedHandCursor;
                            lastAngle = Math.atan2(mouseY - omnitrix.height / 2, mouseX - omnitrix.width / 2) * 180 / Math.PI;
                        }
                        onPositionChanged: (mouse) => {
                            if (!isDragging)
                                return ;

                            let cur = Math.atan2(mouseY - omnitrix.height / 2, mouseX - omnitrix.width / 2) * 180 / Math.PI;
                            let delta = cur - lastAngle;
                            if (delta > 180)
                                delta -= 360;

                            if (delta < -180)
                                delta += 360;

                            omnitrix.ringRotation += delta;
                            lastAngle = cur;
                            if (pfpModel.count === 0)
                                return ;

                            const newIdx = Math.round(((omnitrix.ringRotation % 360) + 360) % 360 / (360 / pfpModel.count)) % pfpModel.count;
                            if (newIdx !== omnitrix.currentIndex) {
                                switchSound.play();
                                omnitrix.currentIndex = newIdx;
                            }
                        }
                        onReleased: {
                            isDragging = false;
                            cursorShape = Qt.OpenHandCursor;
                        }
                    }

                    Behavior on rotation {
                        RotationAnimation {
                            duration: 200
                            direction: RotationAnimation.Shortest
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                WatchRing {
                    implicitWidth: 430
                    implicitHeight: 430
                    color: root.watchBodyOuter

                    border {
                        color: root.watchBodyOuterBorder
                        width: 1
                    }

                }

                WatchRing {
                    implicitWidth: 420
                    implicitHeight: 420
                    color: root.watchBodyMiddle

                    border {
                        color: root.watchBodyMiddleBorder
                        width: 1
                    }

                }

                WatchRing {
                    implicitWidth: 400
                    implicitHeight: 400
                    color: root.watchBodyInner

                    border {
                        color: root.watchBodyInnerBorder
                        width: 1
                    }

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

                            radius: width / 2
                            color: root.centerBgColor
                            antialiasing: true

                            anchors {
                                fill: parent
                                margins: 5
                            }

                            Item {
                                id: hourglassContainer

                                anchors.fill: parent
                                layer.enabled: true
                                layer.smooth: true

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
                                }

                                Repeater {
                                    model: [{
                                        "sx": 0,
                                        "sy": 0,
                                        "ex": 0,
                                        "ey": 1,
                                        "tx": 1
                                    }, {
                                        "sx": 1,
                                        "sy": 0,
                                        "ex": 1,
                                        "ey": 1,
                                        "tx": -1
                                    }]

                                    Shape {
                                        anchors.fill: parent
                                        antialiasing: true
                                        smooth: true
                                        transform: [
                                            Translate {
                                                x: modelData.tx * omnitrix.morphProgress * hourglassContainer.width / 2
                                            },
                                            Scale {
                                                origin.x: hourglassContainer.width / 2
                                                origin.y: hourglassContainer.height / 2
                                                xScale: 1 + omnitrix.morphProgress * 0.05
                                                yScale: 1 + omnitrix.morphProgress * 0.05
                                            }
                                        ]

                                        ShapePath {
                                            fillColor: root.hourglassTriangle
                                            strokeColor: "transparent"
                                            startX: modelData.sx * hourglassContainer.width
                                            startY: modelData.sy * hourglassContainer.height

                                            PathLine {
                                                x: hourglassContainer.width / 2
                                                y: hourglassContainer.height / 2
                                            }

                                            PathLine {
                                                x: modelData.ex * hourglassContainer.width
                                                y: modelData.ey * hourglassContainer.height
                                            }

                                            PathLine {
                                                x: modelData.sx * hourglassContainer.width
                                                y: modelData.sy * hourglassContainer.height
                                            }

                                        }

                                    }

                                }

                                Item {
                                    id: imageContainer

                                    anchors.centerIn: parent
                                    width: parent.width * 0.7 * omnitrix.morphProgress
                                    height: parent.height * 0.7 * omnitrix.morphProgress
                                    rotation: 45
                                    opacity: omnitrix.morphProgress
                                    z: 12
                                    scale: omnitrix.isTransforming ? 1.45 : 1

                                    Rectangle {
                                        anchors.fill: parent
                                        color: root.diamondBg
                                        antialiasing: true

                                        Item {
                                            anchors.fill: parent
                                            clip: true

                                            Image {
                                                anchors.centerIn: parent
                                                width: parent.width * 1.5
                                                height: parent.height * 1.5
                                                source: pfpModel.count > 0 ? (root.pfpsPath + pfpModel.get(omnitrix.currentIndex, "fileName")) : ""
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
                                            transformSound.play();
                                            transformFlashAnim.restart();
                                        }
                                    }

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 500
                                            easing.type: Easing.OutBack
                                            easing.overshoot: 1.3
                                        }

                                    }

                                }

                                layer.effect: OpacityMask {

                                    maskSource: Rectangle {
                                        width: innerGreenRect.width
                                        height: innerGreenRect.height
                                        radius: width / 2
                                    }

                                }

                            }

                        }

                    }

                }

                NumberAnimation on morphProgress {
                    id: morphAnim

                    duration: 400
                    easing.type: Easing.OutCubic
                    running: false
                    onFinished: {
                        if (omnitrix.morphProgress === 1)
                            omnitrix.isTransformed = true;

                    }
                }

            }

        }

    }

    component WatchRing: Rectangle {
        anchors.centerIn: parent
        radius: width / 2
        antialiasing: true
    }

    component SoundPlayer: MediaPlayer {

        audioOutput: AudioOutput {
        }

    }

}
