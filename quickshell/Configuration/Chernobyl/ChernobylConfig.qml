pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool isActive: false
    property real panelHeight: 500

    signal showChernobyl
    signal hideChernobyl

    function dismiss() {
        isActive = false;
        hideChernobyl();
    }
}
