import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    property bool isActive: false

    signal activated()
    signal deactivated()

    function activate() {
        isActive = true;
        activated();
    }

    function deactivate() {
        isActive = false;
        deactivated();
    }

}
