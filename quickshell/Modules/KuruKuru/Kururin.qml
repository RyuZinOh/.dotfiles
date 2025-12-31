import QtQuick
// import QtMultimedia // ts backed wth gstreamer
import qs.Services.Shapes
import qs.Services.Theme

Item {
    id: root
    width: content.width
    height: 140
    property bool isHovered: false
    property bool componentActive: true

    readonly property bool debugMode: true

    Component.onCompleted: {
        if (debugMode) {
            console.log("Component created");
        }
    }

    Component.onDestruction: {
        if (debugMode) {
            console.log("Component being destroyed");
        }
        componentActive = false;
        if (gifSmollLoader.item)
            gifSmollLoader.item.playing = false;
        if (gifBigLoader.item)
            gifBigLoader.item.playing = false;
        if (debugMode) {
            console.log("Cleanup complete");
        }
    }

    // [uncomment to use, i dont want to use ts right now]
    // MediaPlayer {
    //     id: kuruSound
    //     source: "../../Assets/KuruKuru/kururin.mp3"
    //     audioOutput: AudioOutput {}
    // }
    //
    // MediaPlayer {
    //     id: kururinSound
    //     source: "../../Assets/KuruKuru/kuru.mp3"
    //     audioOutput: AudioOutput {}
    // }

    PopoutShape {
        id: content
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 200
        height: root.isHovered ? parent.height : 0.1
        alignment: 5
        radius: root.isHovered ? 20 : 5
        color: Theme.surfaceContainer

        Behavior on height {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutCubic
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutCubic
            }
        }

        Item {
            anchors.fill: parent
            anchors.topMargin: 24
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            anchors.bottomMargin: 24

            opacity: root.isHovered ? 1 : 0
            visible: opacity > 0
            scale: root.isHovered ? 2.7 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 450
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }

            Item {
                id: gifContainer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height

                property bool shouldPlay: root.isHovered && root.componentActive
                property real speed: 0.8
                property bool switchable: true
                property bool showSmoll: true

                Loader {
                    id: gifSmollLoader
                    anchors.fill: parent
                    active: root.isHovered && gifContainer.showSmoll

                    sourceComponent: AnimatedImage {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        fillMode: Image.PreserveAspectFit

                        playing: gifContainer.shouldPlay
                        paused: !gifContainer.shouldPlay
                        source: "../../Assets/KuruKuru/hertaa1.gif"
                        smooth: true
                        cache: false
                        speed: gifContainer.speed

                        Component.onCompleted: {
                            if (root.debugMode) {
                                console.log("small gif loaded");
                            }
                        }

                        Component.onDestruction: {
                            if (root.debugMode) {
                                console.log("small gif  unloaded");
                            }
                        }

                        onVisibleChanged: {
                            if (!visible && !playing) {
                                currentFrame = 0;
                            }
                        }
                    }
                }

                Loader {
                    id: gifBigLoader
                    anchors.fill: parent
                    active: root.isHovered && !gifContainer.showSmoll

                    sourceComponent: AnimatedImage {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        fillMode: Image.PreserveAspectFit

                        playing: gifContainer.shouldPlay
                        paused: !gifContainer.shouldPlay
                        source: "../../Assets/KuruKuru/seseren.gif"
                        smooth: true
                        cache: false
                        speed: gifContainer.speed

                        Component.onCompleted: {
                            if (root.debugMode) {
                                console.log("beeg gif loaded");
                            }
                        }

                        Component.onDestruction: {
                            if (root.debugMode) {
                                console.log("beeg gif unloaded");
                            }
                        }

                        onVisibleChanged: {
                            if (!visible && !playing) {
                                currentFrame = 0;
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.componentActive
                    onPressed: {
                        if (gifContainer.switchable) {
                            if (root.debugMode) {
                                console.log("Switching gif");
                            }
                            gifContainer.showSmoll = !gifContainer.showSmoll;

                            // sound corresponding
                            // if (gifContainer.showSmoll) {
                            //     kuruSound.play();
                            // } else {
                            //     kururinSound.play();
                            // }
                        }
                    }
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            if (root.componentActive) {
                root.isHovered = hovered;
                if (hovered && root.debugMode) {
                    console.log("Hovered: loading GIF");
                } else if (!hovered && root.debugMode) {
                    console.log("Unhovered: unloading GIF");
                }
            }
        }
    }
}
