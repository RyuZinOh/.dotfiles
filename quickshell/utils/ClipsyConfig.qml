import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property bool isActive: false
    property real panelHeight: 500

    signal showClipsy()
    signal hideClipsy()

    function dismiss() {
        isActive = false;
        hideClipsy();
    }

}
