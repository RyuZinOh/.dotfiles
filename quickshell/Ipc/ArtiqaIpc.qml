pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

Item {
    IpcHandler {
        target: "artiqa"

        function toggle(): string {
            if (ArtiqaConfig.isActive) {
                ArtiqaConfig.isActive = false;
                StateManager.set("artiqa", false);
                ArtiqaConfig.hideArtiqa();
            } else {
                ArtiqaConfig.isActive = true;
                StateManager.set("artiqa", true);
                ArtiqaConfig.showArtiqa();
            }
            return "artiqa toggled";
        }

        function activate(): string {
            if (!ArtiqaConfig.isActive) {
                ArtiqaConfig.isActive = true;
                StateManager.set("artiqa", true);
                ArtiqaConfig.showArtiqa();
            }
            return "artiqa shown";
        }

        function deactivate(): string {
            if (ArtiqaConfig.isActive) {
                ArtiqaConfig.isActive = false;
                StateManager.set("artiqa", false);
                ArtiqaConfig.hideArtiqa();
            }
            return "artiqa hidden";
        }
    }
}
