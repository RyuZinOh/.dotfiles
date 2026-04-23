pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool isActive: false
    property real panelHeight: 500

    signal showClipsy
    signal hideClipsy

    function dismiss() {
        isActive = false;
        hideClipsy();
    }
}
