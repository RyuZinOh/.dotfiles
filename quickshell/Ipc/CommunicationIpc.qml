pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Item {
    id: root

    Component.onCompleted: {
        if (CommunicationConfig.hyprsunsetActive)
            Quickshell.execDetached(["hyprsunset", "--temperature", CommunicationConfig.temperature.toString(), "--gamma", CommunicationConfig.gamma.toString()]);
    }

    IpcHandler {
        target: "communication"

        function toggle(): string {
            CommunicationConfig.toggle();
            return CommunicationConfig.hyprsunsetActive ? "hyprsunset on" : "hyprsunset off";
        }

        function increaseTemperature(): string {
            CommunicationConfig.increaseTemperature();
            return "temperature: " + CommunicationConfig.temperature;
        }

        function decreaseTemperature(): string {
            CommunicationConfig.decreaseTemperature();
            return "temperature: " + CommunicationConfig.temperature;
        }

        function increaseGamma(): string {
            CommunicationConfig.increaseGamma();
            return "gamma: " + CommunicationConfig.gamma;
        }

        function decreaseGamma(): string {
            CommunicationConfig.decreaseGamma();
            return "gamma: " + CommunicationConfig.gamma;
        }
    }

    Timer {
        id: startTimer
        interval: 150
        repeat: false
        onTriggered: Quickshell.execDetached(["hyprsunset", "--temperature", CommunicationConfig.temperature.toString(), "--gamma", CommunicationConfig.gamma.toString()])
    }
    Connections {
        target: CommunicationConfig

        function onHyprsunsetToggled(active: bool) {
            Quickshell.execDetached(["pkill", "hyprsunset"]);
            if (active) {
                startTimer.restart();
                Quickshell.execDetached(["notify-send", "Night Mode", "Night mode enabled"]);
            } else {
                Quickshell.execDetached(["notify-send", "Night Mode", "Night mode disabled"]);
            }
        }

        function onTemperatureChanged() {
            if (CommunicationConfig.hyprsunsetActive)
                Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", CommunicationConfig.temperature.toString()]);
        }

        function onGammaChanged() {
            if (CommunicationConfig.hyprsunsetActive)
                Quickshell.execDetached(["hyprctl", "hyprsunset", "gamma", CommunicationConfig.gamma.toString()]);
        }
    }
}
