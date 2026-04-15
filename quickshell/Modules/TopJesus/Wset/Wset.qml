pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.Theme
import qs.utils

Item {
    id: root

    property var currentConfig: ({
        "mode": WallpaperConfig.displayMode,
        "transition": WallpaperConfig.transitionType,
        "panning": WallpaperConfig.enablePanning
    })

    function callIpc(method, arg) {
        Quickshell.execDetached(["quickshell", "ipc", "call", "wallpaper", method, arg]);
    }

    Connections {
        function onDisplayModeChanged() {
            root.currentConfig.mode = WallpaperConfig.displayMode;
            root.currentConfigChanged();
        }

        function onTransitionTypeChanged() {
            root.currentConfig.transition = WallpaperConfig.transitionType;
            root.currentConfigChanged();
        }

        function onEnablePanningChanged() {
            root.currentConfig.panning = WallpaperConfig.enablePanning;
            root.currentConfigChanged();
        }

        target: WallpaperConfig
    }

    IpcHandler {
        function show() : string {
            root.visible = true;
            return "shown";
        }

        function hide() : string {
            root.visible = false;
            return "hidden";
        }

        function toggle() : string {
            root.visible = !root.visible;
            return root.visible ? "shown" : "hidden";
        }

        target: "wset"
    }

    Column {
        anchors.centerIn: parent
        spacing: 12

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: ["wallpaper", "minimal", "disabled"]

                delegate: OptionButton {
                    required property string modelData

                    active: root.currentConfig.mode === modelData
                    label: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                    ipcMethod: "setMode"
                    ipcArg: modelData
                }

            }

        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: ["bubble", "instant"]

                delegate: OptionButton {
                    required property string modelData

                    active: root.currentConfig.transition === modelData
                    enabled: root.currentConfig.mode === "wallpaper"
                    label: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                    ipcMethod: "setTransition"
                    ipcArg: modelData
                }

            }

            OptionButton {
                active: root.currentConfig.panning
                enabled: root.currentConfig.mode === "wallpaper"
                label: root.currentConfig.panning ? "Pan On" : "Pan Off"
                ipcMethod: "setPanning"
                ipcArg: root.currentConfig.panning ? "false" : "true"
            }

        }

    }

    component OptionButton: Item {
        id: btn

        property bool active: false
        // "enabled" is removed — inherited from Item/QQuickItem directly
        property string label: ""
        property string ipcMethod: ""
        property string ipcArg: ""

        width: 80
        height: 80
        opacity: btn.enabled ? 1 : 0.3

        Rectangle {
            anchors.fill: parent
            radius: mouse.containsMouse ? 40 : 12
            color: btn.active ? Theme.primaryContainer : (mouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
            border.width: btn.active ? 2 : 1
            border.color: btn.active ? Theme.primaryColor : Theme.outlineVariant

            Behavior on radius {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 200
                }

            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        Text {
            anchors.centerIn: parent
            text: btn.label
            font.pixelSize: 12
            font.family: "CaskaydiaCove NF"
            font.weight: btn.active ? Font.Medium : Font.Normal
            color: btn.active ? Theme.onPrimaryContainer : Theme.onSurface

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true
            enabled: btn.enabled
            cursorShape: btn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.callIpc(btn.ipcMethod, btn.ipcArg)
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }

        }

    }

}
