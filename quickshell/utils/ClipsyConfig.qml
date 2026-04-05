import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property bool isActive: false

    signal showClipsy()
    signal hideClipsy()

    function dismiss() {
        isActive = false;
        hideClipsy();
    }

}
