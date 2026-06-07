pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.Configuration.Screenshot

IpcHandler {
    target: "screenshot"

    function capture(): string {
        ScreenshotConfig.isCapturing = true;
        return "capturing";
    }

    function captureRegion(): string {
        ScreenshotConfig.isSelectingRegion = true;
        return "selecting region";
    }
    function captureLasso(): string {
        ScreenshotConfig.isLassoing = true;
        return "lassoing";
    }
}
