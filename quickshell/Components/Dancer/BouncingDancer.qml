pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root

    property bool active: false
    property string gifSource: "../../Assets/dancer.gif"

    Loader {
        id: dancerLoader
        active: root.active

        sourceComponent: Component {
            AnimatedImage {
                id: dancer
                width: 150
                height: 150
                source: root.gifSource
                playing: true
                cache: false

                property real velocityX: 5
                property real velocityY: 5
                property real physX: 0
                property real physY: 0
                //laptop screens arent perfect
                readonly property real maxBoundX: root.width - width + 30
                readonly property real maxBoundY: root.height - height + 30

                Component.onCompleted: {
                    physX = Math.random() * maxBoundX;
                    physY = Math.random() * maxBoundY;
                    x = physX;
                    y = physY;
                }

                FrameAnimation {
                    running: true
                    onTriggered: {
                        dancer.physX += dancer.velocityX;
                        dancer.physY += dancer.velocityY;

                        if (dancer.physX <= -30) {
                            dancer.physX = -30;
                            dancer.velocityX = Math.abs(dancer.velocityX) * 1.1;
                        } else if (dancer.physX >= dancer.maxBoundX) {
                            dancer.physX = dancer.maxBoundX;
                            dancer.velocityX = -Math.abs(dancer.velocityX) * 1.1;
                        }

                        if (dancer.physY <= -30) {
                            dancer.physY = -30;
                            dancer.velocityY = Math.abs(dancer.velocityY) * 1.1;
                        } else if (dancer.physY >= dancer.maxBoundY) {
                            dancer.physY = dancer.maxBoundY;
                            dancer.velocityY = -Math.abs(dancer.velocityY) * 1.1;
                        }

                        dancer.velocityX = Math.max(-15, Math.min(15, dancer.velocityX));
                        dancer.velocityY = Math.max(-15, Math.min(15, dancer.velocityY));

                        dancer.x += (dancer.physX - dancer.x) * 0.2;
                        dancer.y += (dancer.physY - dancer.y) * 0.2;
                    }
                }
            }
        }
    }
}
