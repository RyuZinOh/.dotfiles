pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    id: root

    property url assetPath: Qt.resolvedUrl("../../Assets/assets_alpha/")
    property string currentInput: ""
    property var submittedWords: []
    property int wordIdCounter: 0
    property real wordStartTime: 0
    property real wordEndTime: 0
    property var activeTimers: []

    property bool countdownDone: false
    property int countdownValue: 3
    property string countdownText: "3"

    Component.onCompleted: {
        countdownTimer.start();
    }

    Component.onDestruction: {
        for (var i = 0; i < root.activeTimers.length; i++) {
            if (root.activeTimers[i])
                root.activeTimers[i].destroy();
        }
        root.activeTimers = [];
    }

    Timer {
        id: countdownTimer
        interval: 900
        repeat: true
        onTriggered: {
            if (root.countdownValue > 1) {
                root.countdownValue--;
                root.countdownText = root.countdownValue.toString();
                countdownAnim.restart();
            } else if (root.countdownValue === 1) {
                root.countdownText = "STARTCATCHING";
                countdownAnim.restart();
                root.countdownValue = 0;
            } else {
                root.countdownDone = true;
                countdownTimer.stop();
            }
        }
    }

    Timer {
        id: inactivityTimer
        interval: 1000
        repeat: false
        onTriggered: {
            root.currentInput = "";
            root.wordStartTime = 0;
            root.wordEndTime = 0;
        }
    }

    Item {
        anchors.centerIn: parent
        visible: !root.countdownDone

        Text {
            id: countdownLabel
            anchors.centerIn: parent
            visible: root.countdownText !== "STARTCATCHING"
            text: root.countdownText
            font.family: "CaskaydiaCove NF"
            font.pixelSize: 180
            font.bold: true
            color: "white"
            style: Text.Outline
            styleColor: "#000000"
            scale: 1

            SequentialAnimation {
                id: countdownAnim
                running: false
                ParallelAnimation {
                    NumberAnimation {
                        target: countdownLabel
                        property: "scale"
                        from: 2.2
                        to: 1.0
                        duration: 500
                        easing.type: Easing.OutBack
                    }
                    NumberAnimation {
                        target: countdownLabel
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: -6
            visible: root.countdownText === "STARTCATCHING"

            Repeater {
                model: "STARTCATCHING".split("")

                Item {
                    id: scLetter
                    required property string modelData
                    required property int index
                    width: 80
                    height: 80
                    opacity: 0
                    scale: 0.2
                    y: -30

                    Component.onCompleted: scAnim.start()

                    SequentialAnimation {
                        id: scAnim
                        PauseAnimation {
                            duration: scLetter.index * 50
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: scLetter
                                property: "opacity"
                                to: 1
                                duration: 250
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: scLetter
                                property: "scale"
                                to: 1
                                duration: 350
                                easing.type: Easing.OutBack
                            }
                            NumberAnimation {
                                target: scLetter
                                property: "y"
                                to: 0
                                duration: 250
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    Image {
                        anchors.fill: parent
                        source: root.assetPath + scLetter.modelData + ".png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        cache: true
                    }
                }
            }
        }
    }

    Process {
        id: keyboardMonitor
        running: PoketwoConfig.isActive && root.countdownDone
        command: ["cat", "/tmp/poketwo-pipe"]

        stdout: SplitParser {
            onRead: data => {
                var ch = data.toString().trim();

                if (ch === "ENTER") {
                    inactivityTimer.stop();
                    if (root.currentInput.length > 0) {
                        var letters = root.currentInput.split("").filter(c => /[A-Z ]/.test(c));
                        if (letters.length > 0) {
                            var elapsed = (root.wordEndTime - root.wordStartTime) / 60000;
                            var wpm = elapsed > 0 ? Math.round((root.currentInput.length / 5) / elapsed) : 0;
                            var newWord = {
                                letters: letters,
                                id: root.wordIdCounter++,
                                wpm: wpm
                            };
                            root.submittedWords = [newWord];
                            var t = timerComp.createObject(root, {
                                wordId: newWord.id
                            });
                            root.activeTimers.push(t);
                            t.start();
                        }
                        root.currentInput = "";
                        root.wordStartTime = 0;
                        root.wordEndTime = 0;
                    }
                } else if (ch === "BACKSPACE") {
                    if (root.currentInput.length > 0) {
                        root.currentInput = root.currentInput.slice(0, -1);
                        inactivityTimer.restart();
                    }
                } else if (ch === "SPACE") {
                    if (root.currentInput.length > 0 && root.currentInput.length < 32) {
                        root.currentInput += " ";
                        root.wordEndTime = Date.now();
                        inactivityTimer.restart();
                    }
                } else if (ch.length === 1 && root.currentInput.length < 32) {
                    if (root.currentInput.length === 0)
                        root.wordStartTime = Date.now();
                    root.currentInput += ch;
                    root.wordEndTime = Date.now();
                    inactivityTimer.restart();
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                var err = data.toString().trim();
                if (err)
                    console.log("[Poketwo]", err);
            }
        }
    }

    Component {
        id: timerComp
        Timer {
            property int wordId: -1
            interval: 4000
            repeat: false
            onTriggered: {
                root.submittedWords = root.submittedWords.filter(w => w.id !== wordId);
                root.activeTimers = root.activeTimers.filter(t => t !== this);
                destroy();
            }
        }
    }

    Column {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 32
        spacing: 16
        visible: root.countdownDone

        Repeater {
            model: root.submittedWords

            Column {
                id: wordEntry
                required property var modelData
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                spacing: 10
                opacity: 0
                scale: 0.5
                y: 30

                Component.onCompleted: entranceAnim.start()

                ParallelAnimation {
                    id: entranceAnim
                    NumberAnimation {
                        target: wordEntry
                        property: "opacity"
                        to: 1
                        duration: 350
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: wordEntry
                        property: "scale"
                        to: 1
                        duration: 450
                        easing.type: Easing.OutBack
                    }
                    NumberAnimation {
                        target: wordEntry
                        property: "y"
                        to: 0
                        duration: 400
                        easing.type: Easing.OutQuad
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: -4

                    Repeater {
                        model: wordEntry.modelData.wpm.toString().split("")

                        Item {
                            id: wpmDigit
                            required property string modelData
                            required property int index
                            width: 52
                            height: 72
                            opacity: 0
                            scale: 0.3
                            y: -16

                            Component.onCompleted: wpmEntrance.start()

                            SequentialAnimation {
                                id: wpmEntrance
                                PauseAnimation {
                                    duration: wpmDigit.index * 40
                                }
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: wpmDigit
                                        property: "opacity"
                                        to: 1
                                        duration: 220
                                        easing.type: Easing.OutQuad
                                    }
                                    NumberAnimation {
                                        target: wpmDigit
                                        property: "scale"
                                        to: 1
                                        duration: 300
                                        easing.type: Easing.OutBack
                                    }
                                    NumberAnimation {
                                        target: wpmDigit
                                        property: "y"
                                        to: 0
                                        duration: 220
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: wpmDigit.modelData
                                font.family: "CaskaydiaCove NF"
                                font.pixelSize: 52
                                font.bold: true
                                color: {
                                    var w = wordEntry.modelData.wpm;
                                    if (w >= 80)
                                        return "#69ff85";
                                    if (w >= 50)
                                        return "#ffe169";
                                    return "#ff6b6b";
                                }
                                style: Text.Outline
                                styleColor: "#000000"
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: " WPM"
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 36
                        font.bold: true
                        color: "white"
                        opacity: 0.55
                        style: Text.Outline
                        styleColor: "#000000"
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: -6

                    Repeater {
                        model: wordEntry.modelData.letters

                        Item {
                            id: letterItem
                            required property string modelData
                            required property int index
                            width: modelData === " " ? 40 : 92
                            height: 92
                            opacity: 0
                            scale: 0.3
                            y: -20

                            Component.onCompleted: letterEntrance.start()

                            SequentialAnimation {
                                id: letterEntrance
                                PauseAnimation {
                                    duration: letterItem.index * 50
                                }
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: letterItem
                                        property: "opacity"
                                        to: 1
                                        duration: 220
                                        easing.type: Easing.OutQuad
                                    }
                                    NumberAnimation {
                                        target: letterItem
                                        property: "scale"
                                        to: 1
                                        duration: 300
                                        easing.type: Easing.OutBack
                                    }
                                    NumberAnimation {
                                        target: letterItem
                                        property: "y"
                                        to: 0
                                        duration: 220
                                        easing.type: Easing.OutQuad
                                    }
                                }
                            }

                            Image {
                                anchors.fill: parent
                                source: /[A-Z]/.test(letterItem.modelData) ? root.assetPath + letterItem.modelData + ".png" : ""
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                cache: true
                            }
                        }
                    }
                }
            }
        }
    }
}
