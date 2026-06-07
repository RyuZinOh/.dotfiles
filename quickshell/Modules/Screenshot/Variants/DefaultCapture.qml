pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Wayland
import qs.Configuration.Screenshot

Item {
    id: root
    required property var screen

    ScreencopyView {
        id: screencopy
        captureSource: root.screen
        live: false
        width: root.screen.width
        height: root.screen.height

        onHasContentChanged: {
            if (hasContent) {
                screencopy.grabToImage(result => {
                    if (!result) {
                        ScreenshotConfig.dismiss();
                        return;
                    }

                    const bmpPath = "/tmp/qs_screenshot_" + Date.now() + ".bmp";
                    result.saveToFile(bmpPath);

                    ScreenshotConfig.previewPath = bmpPath;
                    ScreenshotConfig.isPreviewing = true;
                    ScreenshotConfig.captureReady(bmpPath);
                    ScreenshotConfig.dismiss();
                });
            }
        }
    }

    Component.onCompleted: screencopy.captureFrame()
}
