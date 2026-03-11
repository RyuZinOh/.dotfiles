pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property bool isActive: false
    signal showPoketwo
    signal hidePoketwo
    signal submitWord(string word)
}
