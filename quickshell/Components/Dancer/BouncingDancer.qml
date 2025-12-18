import QtQuick

Item {
    id: root

    property bool active: false
    property string gifSource: "../../Assets/dancer.gif"

    Loader {
        id: dancerLoader
        active: root.active

        sourceComponent: AnimatedImage {
            id: dancer
            width: 150
            height: 150
            source: root.gifSource
            playing: true
            cache: true

            property real velocityX: 5
            property real velocityY: 5
            //laptop screens arent perfect 
            readonly property real maxX: root.width + 30
            readonly property real maxY: root.height + 30
            readonly property real minX: -30
            readonly property real minY: -30
            readonly property real maxBoundX: maxX - width
            readonly property real maxBoundY: maxY - height

            x: Math.random() * maxBoundX
            y: Math.random() * maxBoundY

            Behavior on x {
                SmoothedAnimation {
                    velocity: 1000
                    duration: 16
                }
            }

            Behavior on y {
                SmoothedAnimation {
                    velocity: 1000
                    duration: 16
                }
            }

            Timer {
                interval: 16
                running: true
                repeat: true
                triggeredOnStart: false

                onTriggered: {
                    var newX = dancer.x + dancer.velocityX;
                    var newY = dancer.y + dancer.velocityY;

                    if (newX <= dancer.minX) {
                        dancer.velocityX = -dancer.velocityX;
                        newX = dancer.minX;
                    } else if (newX >= dancer.maxBoundX) {
                        dancer.velocityX = -dancer.velocityX;
                        newX = dancer.maxBoundX;
                    }

                    if (newY <= dancer.minY) {
                        dancer.velocityY = -dancer.velocityY;
                        newY = dancer.minY;
                    } else if (newY >= dancer.maxBoundY) {
                        dancer.velocityY = -dancer.velocityY;
                        newY = dancer.maxBoundY;
                    }

                    dancer.x = newX;
                    dancer.y = newY;
                }
            }
        }
    }
}
