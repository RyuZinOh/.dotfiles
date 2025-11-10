import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: brightnessRoot

    // publis properties
    property real currentBrightness: 50
    property real maxBrightness: 100

    // exposing the control row
    property alias controlRow: brightnessRow

    Component.onCompleted: {
        brightnessReader.running = true;
        brightnessMaxReader.running = true;
    }

    Process {
        id: brightnessReader
        running: false
        command: ["brightnessctl", "get"]
        stdout: SplitParser {
            onRead: data => {
                brightnessRoot.currentBrightness = parseInt(data.trim());
            }
        }
        onExited: {
            running = false;
        }
    }

    Process {
        id: brightnessMaxReader
        running: false
        command: ["brightnessctl", "max"]
        stdout: SplitParser {
            onRead: data => {
                brightnessRoot.maxBrightness = parseInt(data.trim());
            }
        }
        onExited: {
            running = false;
        }
    }

    Timer {
        id: brightnessUpdateTimer
        interval: 50
        repeat: false
        onTriggered: {
            brightnessReader.running = true;
        }
    }

    ControlRow {
        id: brightnessRow
        anchors.horizontalCenter: parent.horizontalCenter
        iconText: "󰃠"
        iconFamily: "Symbols Nerd Font"
        labelText: "Brightness"
        valueText: Math.round((sliderControl.isPressed ? sliderControl.value : (brightnessRoot.currentBrightness / brightnessRoot.maxBrightness)) * 100) + "%"
        sliderValue: brightnessRoot.currentBrightness / brightnessRoot.maxBrightness
        isDimmed: false
        useVolumeCurve: false
        showIconAnimation: true

        onSliderValueChangedByUser: function (newValue) {
            let brightness = Math.max(1, Math.round(newValue * brightnessRoot.maxBrightness));
            Quickshell.execDetached(["brightnessctl", "set", brightness.toString()]);
            brightnessUpdateTimer.restart();
        }
    }
}
