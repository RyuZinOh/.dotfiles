pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import qs.Services.Paths
import Quickshell.Io
import Quickshell.Services.Pipewire
import Kraken

Singleton {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real sinkVolume: (root.sink?.audio?.volume ?? 0) * 100
    readonly property bool sinkMuted: root.sink?.audio?.muted ?? false

    property string mode: "volume"
    property int currentValue: 0
    property bool isMuted: false
    property bool isVisible: false
    property bool pipewireReady: false

    enum Character {
        Ororon,
        Skirk,
        Chasca
    }

    property int character: OsdConfig.Character.Ororon
    readonly property int maxLimit: 100
    readonly property var characterNames: ["Ororon", "Skirk", "Chasca"]
    readonly property string currentCharacterName: root.characterNames[root.character] || "Ororon"
    readonly property string configPath: PathService.home + "/.cache/safalQuick/osd.json"
    property bool loaded: false

    signal brightnessRead(int value)

    onSinkVolumeChanged: {
        if (root.pipewireReady)
            pushVolumeOsd();
    }
    onSinkMutedChanged: {
        if (root.pipewireReady)
            pushVolumeOsd();
    }

    function pushVolumeOsd() {
        root.mode = "volume";
        root.currentValue = Math.max(0, Math.min(100, Math.round(root.sinkVolume)));
        root.isMuted = root.sinkMuted;
        root.isVisible = true;
        hideTimer.restart();
    }

    function adjustVolume(step: string) {
        const sink = root.sink;
        if (!sink?.audio)
            return;
        const isDown = step.includes("-");
        const val = parseFloat(step.replace("%+", "").replace("%-", "").replace("%", "")) / 100.0;
        const delta = isDown ? -val : val;
        sink.audio.volume = Math.max(0.0, Math.min(1.0, sink.audio.volume + delta));
        sink.audio.muted = false;
    }

    function toggleMute() {
        const sink = root.sink;
        if (!sink?.audio)
            return;
        sink.audio.muted = !sink.audio.muted;
    }

    function readBrightness() {
        brightnessReadExec.running = true;
    }

    function adjustBrightness(step: string) {
        brightnessExec.command = ["sh", "-c", "brightnessctl set " + step + " -q && brightnessctl -m | awk -F, '{print substr($4,1,length($4)-1)}'"];
        brightnessExec.running = true;
    }

    Process {
        id: brightnessReadExec
        command: ["sh", "-c", "brightnessctl -m | awk -F, '{print substr($4,1,length($4)-1)}'"]
        stdout: StdioCollector {
            onStreamFinished: root.brightnessRead(Math.round(parseFloat(text.trim())))
        }
    }

    Process {
        id: brightnessExec
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                root.mode = "brightness";
                root.currentValue = Math.max(0, Math.min(100, Math.round(parseFloat(this.text.trim()))));
                root.isMuted = false;
                root.isVisible = true;
                hideTimer.restart();
            }
        }
    }

    function saveConfig() {
        configKraken.set("character", root.character);
        configKraken.save();
    }

    Timer {
        id: hideTimer
        interval: 2000
        running: root.isVisible
        onTriggered: root.isVisible = false
    }

    Timer {
        interval: 500
        running: true
        repeat: false
        onTriggered: root.pipewireReady = true
    }

    Kraken {
        id: configKraken
        filePath: root.configPath
        onDataLoaded: {
            if (isObject && has("character"))
                root.character = get("character", 0);
            root.loaded = true;
        }
        onLoadFailed: error => {
            root.character = OsdConfig.Character.Ororon;
            root.loaded = true;
            root.saveConfig();
        }
    }

    Component.onCompleted: configKraken.reload()
}
