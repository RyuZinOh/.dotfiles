import QtQuick
import Quickshell.Io

Item {
    id: root

    property int size: 64
    property url assetPath: Qt.resolvedUrl("../../Assets/bongo/")

    width: size
    height: size

    property bool leftHandActive: false
    property bool rightHandActive: false
    property int keypressCount: 0

    property bool lastWasLeft: false
    Process {
        id: keyboardMonitor
        running: true
        command: ["cat", "/tmp/bongo-pipe"]
        stdout: SplitParser {
            onRead: data => {
                // console.log("[BongoCat] got:", data.toString().trim());
                root.handleKeyPress();
            }
        }
        stderr: SplitParser {
            onRead: data => console.log("[BongoCat] err:", data.toString().trim())
        }
    }
    function handleKeyPress() {
        keypressCount++;
        if (!lastWasLeft) {
            leftHandActive = true;
            leftHandTimer.restart();
            lastWasLeft = true;
        } else {
            rightHandActive = true;
            rightHandTimer.restart();
            lastWasLeft = false;
        }
    }

    Timer {
        id: leftHandTimer
        interval: 120
        onTriggered: root.leftHandActive = false
    }

    Timer {
        id: rightHandTimer
        interval: 120
        onTriggered: root.rightHandActive = false
    }

    function getCurrentImage() {
        if (leftHandActive && rightHandActive) {
            return assetPath + "/bongo-cat-both-up.png";
        } else if (leftHandActive) {
            return assetPath + "/bongo-cat-left-down.png";
        } else if (rightHandActive) {
            return assetPath + "/bongo-cat-right-down.png";
        } else {
            return assetPath + "/bongo-cat-both-down.png";
        }
    }

    Image {
        id: bongoImage
        anchors.fill: parent
        source: root.getCurrentImage()
        fillMode: Image.PreserveAspectFit
        smooth: true
        cache: true
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        // width: statusText.width + 4
        // height: statusText.height + 2
        color: "black"
        opacity: 0.8
        // visible: keypressCount > 0

        // Text {
        //     id: statusText
        //     anchors.centerIn: parent
        //     text: keypressCount
        //     color: (leftHandActive || rightHandActive) ? "blue" : "white"
        //     font.pixelSize: 8
        // }
    }
    // Component.onCompleted: {
    // console.log("[BongoCat] initiated.");
    // console.log("[BongoCat] begin fingering...");
    // }
}
