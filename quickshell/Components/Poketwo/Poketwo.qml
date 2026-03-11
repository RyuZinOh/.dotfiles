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

    property bool countdownDone: false
    property int countdownValue: 3
    property string countdownText: "3"

    Component.onCompleted: {
        countdownTimer.start();
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

    Item {
        anchors.centerIn: parent
        visible: !root.countdownDone

        // 3 2 1 big text
        Text {
            id: countdownLabel
            anchors.centerIn: parent
            visible: root.countdownText !== "STARTCATCHING"
            text: root.countdownText
            font.family: "CaskaydiaCove NF"
            font.pixelSize: 140
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
                        from: 1.8
                        to: 1.0
                        duration: 400
                        easing.type: Easing.OutBack
                    }
                    NumberAnimation {
                        target: countdownLabel
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

        // STARTCATCHING as sprites
        Row {
            anchors.centerIn: parent
            spacing: -8
            visible: root.countdownText === "STARTCATCHING"

            Repeater {
                model: "STARTCATCHING".split("")

                Item {
                    id: scLetter
                    required property string modelData
                    required property int index
                    width: 64
                    height: 64
                    opacity: 0
                    scale: 0.3
                    y: -20

                    Component.onCompleted: scAnim.start()

                    SequentialAnimation {
                        id: scAnim
                        PauseAnimation {
                            duration: scLetter.index * 60
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: scLetter
                                property: "opacity"
                                to: 1
                                duration: 200
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: scLetter
                                property: "scale"
                                to: 1
                                duration: 250
                                easing.type: Easing.OutBack
                            }
                            NumberAnimation {
                                target: scLetter
                                property: "y"
                                to: 0
                                duration: 200
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
        command: ["python3", Qt.resolvedUrl("../../Scripts/poketwo_monitor.py").toString().replace("file://", "")]

        stdout: SplitParser {
            onRead: data => {
                var ch = data.toString().trim();

                if (ch === "ENTER") {
                    idleTimer.stop();
                    if (root.currentInput.length > 0) {
                        var letters = root.currentInput.split("").filter(c => /[A-Z]/.test(c));
                        if (letters.length > 0) {
                            var elapsed = (Date.now() - root.wordStartTime) / 60000;
                            var wpm = elapsed > 0 ? Math.round((letters.length / 5) / elapsed) : 0;
                            var newWord = {
                                letters: letters,
                                id: root.wordIdCounter++,
                                wpm: wpm
                            };
                            root.submittedWords = [newWord];
                            wordCleanupTimer.addWord(newWord.id);
                        }
                        root.currentInput = "";
                        root.wordStartTime = 0;
                    }
                } else if (ch === "BACKSPACE") {
                    if (root.currentInput.length > 0)
                        root.currentInput = root.currentInput.slice(0, -1);
                } else if (ch === "SPACE") {
                    // ignore space
                } else if (ch.length === 1 && root.currentInput.length < 16) {
                    if (root.currentInput.length === 0)
                        root.wordStartTime = Date.now();
                    root.currentInput += ch;
                    idleTimer.restart();
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                var err = data.toString().trim();
                if (err.includes("Permission denied"))
                    console.log("[Poketwo] permission denied — run: sudo usermod -a -G input $USER");
                else if (err)
                    console.log("[Poketwo]", err);
            }
        }
    }

    Timer {
        id: idleTimer
        interval: 3000
        repeat: false
        onTriggered: {
            root.currentInput = "";
            root.wordStartTime = 0;
        }
    }

    QtObject {
        id: wordCleanupTimer
        function addWord(wid) {
            timerComp.createObject(root, {
                wordId: wid
            }).start();
        }
        function removeWord(wid) {
            root.submittedWords = root.submittedWords.filter(w => w.id !== wid);
        }
    }

    Component {
        id: timerComp
        Timer {
            property int wordId: -1
            interval: 3000
            repeat: false
            onTriggered: {
                wordCleanupTimer.removeWord(wordId);
                destroy();
            }
        }
    }

    Column {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        spacing: 10
        visible: root.countdownDone

        Repeater {
            model: root.submittedWords

            Column {
                id: wordEntry
                required property var modelData
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                spacing: 2
                opacity: 0
                scale: 0.7

                Component.onCompleted: entranceAnim.start()

                ParallelAnimation {
                    id: entranceAnim
                    NumberAnimation {
                        target: wordEntry
                        property: "opacity"
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: wordEntry
                        property: "scale"
                        to: 1
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: -6

                    Repeater {
                        model: (wordEntry.modelData.wpm.toString() + " WPM").split("").filter(c => c !== " ")

                        Item {
                            required property string modelData
                            required property int index
                            width: 56
                            height: 56

                            Image {
                                anchors.fill: parent
                                visible: /[A-Z]/.test(modelData)
                                source: /[A-Z]/.test(modelData) ? root.assetPath + modelData + ".png" : ""
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                cache: true
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: /[0-9]/.test(modelData)
                                text: modelData
                                font.family: "CaskaydiaCove NF"
                                font.pixelSize: 40
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
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: -8

                    Repeater {
                        model: wordEntry.modelData.letters

                        Item {
                            id: letterItem
                            required property string modelData
                            required property int index
                            width: 72
                            height: 72
                            opacity: 0
                            scale: 0.4
                            y: -10

                            Component.onCompleted: letterEntrance.start()

                            SequentialAnimation {
                                id: letterEntrance
                                PauseAnimation {
                                    duration: letterItem.index * 60
                                }
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: letterItem
                                        property: "opacity"
                                        to: 1
                                        duration: 200
                                        easing.type: Easing.OutQuad
                                    }
                                    NumberAnimation {
                                        target: letterItem
                                        property: "scale"
                                        to: 1
                                        duration: 200
                                        easing.type: Easing.OutBack
                                    }
                                    NumberAnimation {
                                        target: letterItem
                                        property: "y"
                                        to: 0
                                        duration: 200
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
