pragma Singleton
import QtQuick
import Quickshell

QtObject {
    readonly property string home: Quickshell.env("HOME")
    readonly property string state: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/safalQuick"
}
