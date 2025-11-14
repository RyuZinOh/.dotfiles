import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: volumeRoot

    // Public properties
    property real currentVolume: 0.5
    property bool isMuted: false

    // exposing the control row
    property alias controlRow: volumeRow

    Component.onCompleted: {
        updateVolume();
    }

    function updateVolume() {
        volumeReader.running = true;
    }

    Process {
        id: volumeReader
        running: false
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                let text = data.trim();
                volumeRoot.isMuted = text.includes("MUTED");
                let match = text.match(/[\d.]+/);
                if (match) {
                    volumeRoot.currentVolume = parseFloat(match[0]);
                }
            }
        }
        onExited: {
            running = false;
        }
    }

    Timer {
        id: volumeUpdateTimer
        interval: 50
        repeat: false
        onTriggered: updateVolume()
    }

    ControlRow {
        id: volumeRow
        anchors.horizontalCenter: parent.horizontalCenter
        iconText: {
            if (volumeRoot.isMuted) {
                return "󰝟";
            }
            let vol = volumeRoot.currentVolume;
            if (vol > 0.66) {
                return "󰕾";
            }
            if (vol > 0.33) {
                return "󰖀";
            }
            if (vol > 0) {
                return "󰕿";
            }
            return "󰝟";
        }
        iconFamily: "CaskaydiaCove NF"
        labelText: "Volume"
        valueText: volumeRoot.isMuted ? "Muted" : Math.round((sliderControl.isPressed ? sliderControl.value : volumeRoot.currentVolume) * 100) + "%"
        sliderValue: volumeRoot.currentVolume
        isDimmed: volumeRoot.isMuted
        useVolumeCurve: true
        showIconAnimation: false
        iconClickable: true

        onIconClicked: {
            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
            volumeUpdateTimer.restart();
        }

        onSliderValueChangedByUser: function (newValue) {
            let linearValue = Math.pow(newValue, 0.666667);
            let percentage = Math.round(linearValue * 100);
            Quickshell.execDetached(["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", percentage + "%"]);
            if (volumeRoot.isMuted && percentage > 0) {
                Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"]);
            }
            volumeUpdateTimer.restart();
        }
    }
}
