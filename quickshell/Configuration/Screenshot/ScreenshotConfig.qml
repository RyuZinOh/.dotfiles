pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool isSelectingRegion: false
    property bool isLassoing: false
    property bool isCapturing: false
    property bool isPreviewing: false
    property string previewPath: ""

    property rect selectedRegion: Qt.rect(0, 0, 0, 0)
    property var lassoPoints: []

    readonly property bool isActive: isSelectingRegion || isLassoing || isCapturing || isPreviewing

    signal captureReady(string path)

    function dismiss() {
        isCapturing = false;
        isSelectingRegion = false;
        isLassoing = false;
        selectedRegion = Qt.rect(0, 0, 0, 0);
        lassoPoints = [];
    }

    function dismissPreview() {
        isPreviewing = false;
        previewPath = "";
    }
}
