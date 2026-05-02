pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "osd"

        function volume(step: string): string {
            if (!step || step.length === 0)
                return "Invalid step";
            OsdConfig.adjustVolume(step);
            return "ok";
        }

        function mute(): string {
            OsdConfig.toggleMute();
            return "ok";
        }

        function brightness(step: string): string {
            if (!step || step.length === 0)
                return "Invalid step";
            OsdConfig.adjustBrightness(step);
            return "ok";
        }

        function setCharacter(name: string): string {
            const idx = OsdConfig.characterNames.findIndex(n => n.toLowerCase() === name.toLowerCase());
            if (idx !== -1) {
                OsdConfig.character = idx;
                OsdConfig.saveConfig();
                return "Character set to " + OsdConfig.characterNames[idx];
            }
            return "Invalid character. Available: " + OsdConfig.characterNames.join(", ");
        }

        function nextCharacter(): string {
            OsdConfig.character = (OsdConfig.character + 1) % OsdConfig.characterNames.length;
            OsdConfig.saveConfig();
            return "Character set to " + OsdConfig.currentCharacterName;
        }

        function getConfig(): string {
            return "character: " + OsdConfig.currentCharacterName;
        }
    }
}
