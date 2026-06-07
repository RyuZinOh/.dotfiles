pragma ComponentBehavior: Bound

import QtQuick
import qs.Configuration.Screenshot
import "./Variants"

Item {
    id: root
    required property var screen

    Loader {
        anchors.fill: parent
        active: ScreenshotConfig.isCapturing
        sourceComponent: Component {
            DefaultCapture {
                screen: root.screen
            }
        }
    }
    Loader {
        anchors.fill: parent
        active: ScreenshotConfig.isSelectingRegion
        sourceComponent: Component {
            RegionCapture {
                screen: root.screen
            }
        }
    }
    Loader {
        id: lassoCaptureLoader
        anchors.fill: parent
        active: ScreenshotConfig.isLassoing
        sourceComponent: Component {
            LassoCapture {
                screen: root.screen
            }
        }
    }
    Loader {
        anchors.fill: parent
        active: ScreenshotConfig.isPreviewing
        sourceComponent: Component {
            ScreenshotPreview {}
        }
    }
}
