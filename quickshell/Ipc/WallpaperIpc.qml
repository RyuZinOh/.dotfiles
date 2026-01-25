pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    id: root

    IpcHandler {
        target: "wallpaper"

        function setWallpaper(path: string): string {
            const fullPath = path.startsWith("file://") ? path : "file://" + path;
            WallpaperConfig.currentWallpaper = fullPath;
            WallpaperConfig.saveConfig();
            return "ok";
        }

        function setMode(mode: string): string {
            if (mode === "wallpaper" || mode === "minimal" || mode === "disabled") {
                WallpaperConfig.displayMode = mode;
                if (mode === "minimal" || mode === "disabled") {
                    WallpaperConfig.transitionType = "instant";
                    WallpaperConfig.enablePanning = false;
                }
                WallpaperConfig.saveConfig();
                return "ok";
            }
            return "invalid mode";
        }

        function setTransition(type: string): string {
            if (WallpaperConfig.displayMode !== "wallpaper") {
                return "wallpaper mode only";
            }

            if (type === "bubble" || type === "instant") {
                WallpaperConfig.transitionType = type;
                WallpaperConfig.saveConfig();
                return "ok";
            }
            return "invalid transition";
        }

        function setPanning(enabled: string): string {
            if (WallpaperConfig.displayMode !== "wallpaper") {
                return "wallpaper mode only";
            }

            WallpaperConfig.enablePanning = (enabled === "true" || enabled === "1");
            WallpaperConfig.saveConfig();
            return "ok";
        }

        function getConfig(): string {
            return "wallpaper: " + WallpaperConfig.currentWallpaper + "\n" + "mode: " + WallpaperConfig.displayMode + "\n" + "transition: " + WallpaperConfig.transitionType + "\n" + "panning: " + WallpaperConfig.enablePanning;
        }
    }
}
