pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentWallpaper: ""
    readonly property string persistPath: Quickshell.env("HOME") + "/.cache/safalQuick/persist" //caching the path here for persistance

    FileView {
        id: persistFile
        path: root.persistPath
        watchChanges: true

        onFileChanged: loadWallpaper()
        Component.onCompleted: loadWallpaper()
    }

    // IPC Handler for external wallpaper changes
    IpcHandler {
        target: "wallpaper"

        function setWallpaper(path: string) {
            const fullPath = path.startsWith("file://") ? path : "file://" + path;
            root.currentWallpaper = fullPath;
            saveWallpaper(fullPath);
        }
    }

    function saveWallpaper(path: string) {
        saveProc.command = ["bash", "-c", `mkdir -p "$(dirname '${persistPath}')" && echo '${path}' > '${persistPath}'`];
        saveProc.running = true;
    }

    function loadWallpaper() {
        loadProc.running = true;
    }

    Process {
        id: saveProc
        command: []
        running: false

        stderr: SplitParser {
            onRead: data => {
                if (data.trim()) {
                    console.warn("Save wallpaper error:", data);
                }
            }
        }
    }

    Process {
        id: loadProc
        command: ["cat", root.persistPath]
        running: false

        stdout: SplitParser {
            onRead: data => {
                const trimmed = data.trim();
                if (trimmed && trimmed !== root.currentWallpaper) {
                    root.currentWallpaper = trimmed;
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.log("no persistFile");
            }
        }
    }
}
