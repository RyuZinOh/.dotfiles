pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    property bool isCapturing: false
    property bool isSelectingRegion: false
    property bool isPreviewing: false
    property bool silent: false
    property string previewPath: ""
    property rect selectedRegion: Qt.rect(0, 0, 0, 0)

    signal captureReady(string path)

    function dismiss() {
        isCapturing = false;
        isSelectingRegion = false;
        selectedRegion = Qt.rect(0, 0, 0, 0);
    }

    function dismissPreview() {
        isPreviewing = false;
        previewPath = "";
    }
}
