pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    id: root

    Timer {
        id: hideTimer
        interval: 2000
        running: OsdConfig.isVisible
        onTriggered: OsdConfig.isVisible = false
    }

    Process {
        id: volumeExec
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(" ");
                OsdConfig.mode = "volume";
                OsdConfig.currentValue = Math.max(0, Math.min(100, Math.round(parseFloat(parts[0]))));
                OsdConfig.isMuted = parts.length > 1 && (parts[1] === "[MUTED]" || parts[1] === "[OFF]");
                OsdConfig.isVisible = true;
                hideTimer.restart();
            }
        }
    }

    Process {
        id: brightnessExec
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                OsdConfig.mode = "brightness";
                OsdConfig.currentValue = Math.max(0, Math.min(100, Math.round(parseFloat(this.text.trim()))));
                OsdConfig.isMuted = false;
                OsdConfig.isVisible = true;
                hideTimer.restart();
            }
        }
    }

    IpcHandler {
        target: "osd"

        function volume(step: string): string {
            volumeExec.command = ["sh", "-c", "wpctl set-volume @DEFAULT_SINK@ " + step + " -l 1.0 && wpctl get-volume @DEFAULT_SINK@ | awk '{print $2 * 100, $3}'"];
            volumeExec.running = true;
            return "Volume adjusted";
        }

        function mute(): string {
            volumeExec.command = ["sh", "-c", "wpctl set-mute @DEFAULT_SINK@ toggle && wpctl get-volume @DEFAULT_SINK@ | awk '{print $2 * 100, $3}'"];
            volumeExec.running = true;
            return "Mute toggled";
        }

        function brightness(step: string): string {
            brightnessExec.command = ["sh", "-c", "brightnessctl set " + step + " -q && brightnessctl -m | awk -F, '{print substr($4, 1, length($4)-1)}'"];
            brightnessExec.running = true;
            return "Brightness adjusted";
        }
    }
}
