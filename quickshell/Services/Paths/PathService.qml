pragma Singleton
import QtQuick
import Quickshell

QtObject {
    readonly property string home: Quickshell.env("HOME")
}
