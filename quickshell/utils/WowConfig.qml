pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property bool isActive: false
    signal showWow
    signal hideWow
}
