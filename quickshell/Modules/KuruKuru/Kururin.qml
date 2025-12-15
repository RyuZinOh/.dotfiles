import QtQuick
// import QtMultimedia // ts backed wth gstreamer
import qs.Services.Shapes

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
        style: 1
        alignment: 5
        radius: root.isHovered ? 20 : 5
        color: "black"

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

                property bool playing: true
                property real speed: 0.8
                property bool switchable: true

                AnimatedImage {
                    id: gifSmoll
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    fillMode: Image.PreserveAspectFit

                    playing: gifContainer.playing && gifSmoll.visible
                    source: "../../Assets/KuruKuru/hertaa1.gif"
                    smooth: true
                    cache: true
                    speed: gifContainer.speed
                }

                AnimatedImage {
                    id: gifBig
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    fillMode: Image.PreserveAspectFit

                    playing: gifContainer.playing && gifBig.visible
                    source: "../../Assets/KuruKuru/seseren.gif"
                    smooth: true
                    cache: true
                    speed: gifContainer.speed
                    visible: false
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
