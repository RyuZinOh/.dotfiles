import QtQuick
// import QtMultimedia // ts backed wth gstreamer
import qs.Services.Shapes
import qs.Services.Theme

Item {
    id: root
    width: content.width
    height: 140
    property bool isHovered: false

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
            anchors.bottomMargin: -20

            opacity: root.isHovered ? 1 : 0
            visible: opacity > 0
            scale: root.isHovered ? 1 : 0.85

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

                property bool shouldPlay: root.isHovered
                property real speed: 0.8
                property bool switchable: true

                AnimatedImage {
                    id: gifSmoll
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    fillMode: Image.PreserveAspectFit

                    playing: gifContainer.shouldPlay && gifSmoll.visible
                    paused: !gifContainer.shouldPlay
                    source: "../../Assets/KuruKuru/hertaa1.gif"
                    smooth: true
                    cache: false
                    speed: gifContainer.speed

                    //reset to first frame when not visible/playing
                    onVisibleChanged: {
                        if (!visible && !playing) {
                            currentFrame = 0;
                        }
                    }
                }

                AnimatedImage {
                    id: gifBig
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    fillMode: Image.PreserveAspectFit

                    playing: gifContainer.shouldPlay && gifBig.visible
                    paused: !gifContainer.shouldPlay
                    source: "../../Assets/KuruKuru/seseren.gif"
                    smooth: true
                    cache: false
                    speed: gifContainer.speed
                    visible: false

                    onVisibleChanged: {
                        if (!visible && !playing) {
                            currentFrame = 0;
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        if (gifContainer.switchable) {
                            gifSmoll.visible = !gifSmoll.visible;
                            gifBig.visible = !gifBig.visible;

                            // sound corresponding
                            // if (gifSmoll.visible) {
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
        onHoveredChanged: root.isHovered = hovered
    }
}
