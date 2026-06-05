pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Wayland
import qs.Configuration.Screenshot

Item {
    id: root
    required property var screen

    Item {
        id: cropWrapper
        width: ScreenshotConfig.selectedRegion.width > 0 ? ScreenshotConfig.selectedRegion.width : root.screen.width
        height: ScreenshotConfig.selectedRegion.height > 0 ? ScreenshotConfig.selectedRegion.height : root.screen.height
        clip: true

        ScreencopyView {
            id: screencopy
            captureSource: root.screen
            live: false
            width: root.screen.width
            height: root.screen.height
            x: ScreenshotConfig.selectedRegion.width > 0 ? -ScreenshotConfig.selectedRegion.x : 0
            y: ScreenshotConfig.selectedRegion.height > 0 ? -ScreenshotConfig.selectedRegion.y : 0

            onHasContentChanged: {
                if (hasContent) {
                    cropWrapper.grabToImage(result => {
                        if (!result) {
                            ScreenshotConfig.dismiss();
                            return;
                        }
                        const timestamp = Date.now();
                        const tmp = "/tmp/qs_screenshot_" + timestamp + ".bmp";
                        result.saveToFile(tmp);
                        // ScreenshotConfig.previewPath = tmp;
                        // ScreenshotConfig.isPreviewing = true;
                        if (!ScreenshotConfig.silent) {
                            ScreenshotConfig.previewPath = tmp;
                            ScreenshotConfig.isPreviewing = true;
                        }
                        ScreenshotConfig.captureReady(tmp);
                        ScreenshotConfig.dismiss();
                    });
                }
            }
        }
    }

    Timer {
        id: rapidCaptureTimer
        interval: 200
        repeat: false
        running: true
        onTriggered: screencopy.captureFrame()
    }
}
