pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string currentWallpaper: ""
    property string displayMode: "wallpaper"
    property string transitionType: "bubble"
    property bool enablePanning: true
    readonly property string persistPath: Quickshell.env("HOME") + "/.cache/safalQuick/persist" //caching the path here for persistance
    readonly property int bubbleDuration: transitionType === "bubble" ? 1000 : 0
    readonly property string configPath: Quickshell.env("HOME") + "/.cache/safalQuick/wallpaper-config.json"
    property bool loaded: false
    property bool loading: false

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        onFileChanged: {
            loadConfig();
        }
    }

    FileView {
        id: persistFile
        path: root.persistPath
        watchChanges: true
        onFileChanged: {
            loadWallpaper();
        }
    }

    Component.onCompleted: {
        loadConfig();
        loadWallpaper();
    }

    // IPC Handler for external wallpaper changes
    IpcHandler {
        target: "wallpaper"

        function setWallpaper(path: string): string {
            const fullPath = path.startsWith("file://") ? path : "file://" + path;
            root.currentWallpaper = fullPath;
            saveWallpaper(fullPath);
            return "wallpaper set to: " + path;
        }

        function setMode(mode: string): string {
            if (mode === "wallpaper" || mode === "minimal" || mode === "disabled") {
                root.displayMode = mode;
                if (mode === "minimal" || mode === "disabled") {
                    root.transitionType = "instant";
                    root.enablePanning = false;
                }
                saveConfig();
                let msg = "Display mode set to: " + mode;
                if (mode !== "wallpaper") {
                    msg += "\n  → transition and panning not application in this mode";
                }
                return msg;
            } else {
                return "ERROR: Invalid mode '" + mode + "' - use-> wallpaper, minimal, disabled";
            }
        }

        function setTransition(type: string): string {
            if (root.displayMode !== "wallpaper") {
                return "ERROR: Cannot set transition in " + root.displayMode + " mode - switch to wallpaper mode first";
            }

            if (type === "bubble" || type === "instant") {
                root.transitionType = type;
                saveConfig();
                return "Transition type set to: " + type;
            } else {
                return "ERROR: Invalid transition type '" + type + "' - Valid types: bubble, instant";
            }
        }

        function setPanning(enabled: string): string {
            if (root.displayMode !== "wallpaper") {
                return "ERROR: Panning only works in wallpaper mode";
            }

            root.enablePanning = (enabled === "true" || enabled === "1");
            saveConfig();
            return "Panning set to: " + root.enablePanning;
        }

        function getConfig(): string {
            return "  wallpaper: " + root.currentWallpaper + "\n" + "  mode: " + root.displayMode + "\n" + "  transition: " + root.transitionType + " (only in wallpaper mode)\n" + "  panning: " + root.enablePanning + " (only in wallpaper mode)\n" + "  bubbleDuration: " + root.bubbleDuration + "ms (auto-set based on transition)\n";
        }
    }

    function loadConfig() {
        if (loading) {
            return;
        }
        loading = true;

        const proc = loadConfigProcess.createObject(root);
        proc.start();
    }

    property Component loadConfigProcess: Component {
        Process {
            id: proc
            command: ["cat", root.configPath]
            running: false
            property string output: ""

            stdout: SplitParser {
                onRead: data => proc.output += data
            }

            onExited: (code, status) => {
                root.loading = false;

                if (code === 0) {
                    const trimmed = proc.output.trim();
                    if (trimmed) {
                        try {
                            const config = JSON.parse(trimmed);

                            if (config.displayMode) {
                                root.displayMode = config.displayMode;
                            }
                            if (config.transitionType) {
                                root.transitionType = config.transitionType;
                            }
                            if (config.enablePanning !== undefined) {
                                root.enablePanning = config.enablePanning;
                            }
                            root.loaded = true;
                        } catch (e) {
                            saveConfig();
                        }
                    } else {
                        saveConfig();
                    }
                } else {
                    saveConfig();
                }
                destroy();
            }
            function start() {
                running = true;
            }
        }
    }

    function saveConfig() {
        const config = {
            displayMode: root.displayMode,
            transitionType: root.transitionType,
            enablePanning: root.enablePanning
        };

        const jsonStr = JSON.stringify(config, null, 2);
        const escapedJson = jsonStr.replace(/'/g, "'\\''");

        const proc = saveConfigProcess.createObject(root, {
            jsonContent: escapedJson
        });
        proc.start();
    }

    property Component saveConfigProcess: Component {
        Process {
            id: proc
            property string jsonContent: ""

            command: ["bash", "-c", `mkdir -p "$(dirname '${root.configPath}')" && echo '${jsonContent}' > '${root.configPath}'`]
            running: false

            stderr: SplitParser {
                onRead: data => {
                    if (data.trim()) {
                        console.warn("Save config error:", data);
                    }
                }
            }

            onExited: (code, status) => {
                destroy();
            }

            function start() {
                running = true;
            }
        }
    }

    function loadWallpaper() {
        const proc = loadWallpaperProcess.createObject(root);
        proc.start();
    }

    property Component loadWallpaperProcess: Component {
        Process {
            id: proc
            command: ["cat", root.persistPath]
            running: false
            property string output: ""

            stdout: SplitParser {
                onRead: data => proc.output += data
            }

            onExited: (code, status) => {
                if (code === 0) {
                    const trimmed = proc.output.trim();
                    if (trimmed && trimmed !== root.currentWallpaper) {
                        root.currentWallpaper = trimmed;
                    }
                }
                destroy();
            }

            function start() {
                running = true;
            }
        }
    }

    function saveWallpaper(path: string) {
        const proc = saveWallpaperProcess.createObject(root, {
            wallpaperPath: path
        });
        proc.start();
    }

    property Component saveWallpaperProcess: Component {
        Process {
            id: proc
            property string wallpaperPath: ""

            command: ["bash", "-c", `mkdir -p "$(dirname '${root.persistPath}')" && echo '${wallpaperPath}' > '${root.persistPath}'`]
            running: false

            stderr: SplitParser {
                onRead: data => {
                    if (data.trim()) {
                        console.warn("Save wallpaper error:", data);
                    }
                }
            }
            onExited: (code, status) => {
                destroy();
            }
            function start() {
                running = true;
            }
        }
    }
}
