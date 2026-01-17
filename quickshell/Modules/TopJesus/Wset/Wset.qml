import QtQuick
import Quickshell.Io
import qs.Services.Theme
import qs.Data

Item {
    id: root

    property var currentConfig: ({
            mode: WallpaperConfigAdapter.displayMode,
            transition: WallpaperConfigAdapter.transitionType,
            panning: WallpaperConfigAdapter.enablePanning
        })

    Connections {
        target: WallpaperConfigAdapter

        function onDisplayModeChanged() {
            currentConfig.mode = WallpaperConfigAdapter.displayMode;
            currentConfigChanged();
        }

        function onTransitionTypeChanged() {
            currentConfig.transition = WallpaperConfigAdapter.transitionType;
            currentConfigChanged();
        }

        function onEnablePanningChanged() {
            currentConfig.panning = WallpaperConfigAdapter.enablePanning;
            currentConfigChanged();
        }
    }

    IpcHandler {
        target: "wset"

        function show(): string {
            root.visible = true;
            return "Settings panel shown";
        }

        function hide(): string {
            root.visible = false;
            return "Settings panel hidden";
        }

        function toggle(): string {
            root.visible = !root.visible;
            return root.visible ? "Settings panel shown" : "Settings panel hidden";
        }
    }

    function callIpc(method, arg) {
        var proc = ipcProcess.createObject(root, {
            method: method,
            argument: arg
        });
        proc.start();
    }

    property Component ipcProcess: Component {
        Process {
            id: proc
            property string method: ""
            property string argument: ""

            command: ["quickshell", "ipc", "call", "wallpaper", method, argument]
            running: false

            onExited: function (code, status) {
                destroy();
            }

            function start() {
                running = true;
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 280
        height: 212
        color: Theme.surfaceContainer
        radius: 16
        border.width: 1
        border.color: Theme.outlineVariant

        Column {
            anchors.centerIn: parent
            spacing: 12

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Repeater {
                    model: ["wallpaper", "minimal", "disabled"]

                    Rectangle {
                        width: 80
                        height: 80
                        radius: displayMouse.containsMouse ? 40 : 12
                        color: currentConfig.mode === modelData ? Theme.primaryContainer : (displayMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                        border.width: currentConfig.mode === modelData ? 2 : 1
                        border.color: currentConfig.mode === modelData ? Theme.primaryColor : Theme.outlineVariant

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

                        Text {
                            anchors.centerIn: parent
                            text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                            font.pixelSize: 12
                            font.family: "CaskaydiaCove NF"
                            font.weight: currentConfig.mode === modelData ? Font.Medium : Font.Normal
                            color: currentConfig.mode === modelData ? Theme.onPrimaryContainer : Theme.onSurface

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }

                        MouseArea {
                            id: displayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                callIpc("setMode", modelData);
                            }
                        }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Repeater {
                    model: ["bubble", "instant"]

                    Rectangle {
                        width: 80
                        height: 80
                        radius: transitionMouse.containsMouse ? 40 : 12
                        color: currentConfig.transition === modelData ? Theme.primaryContainer : (transitionMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                        border.width: currentConfig.transition === modelData ? 2 : 1
                        border.color: currentConfig.transition === modelData ? Theme.primaryColor : Theme.outlineVariant
                        opacity: currentConfig.mode === "wallpaper" ? 1.0 : 0.3

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }

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

                        Text {
                            anchors.centerIn: parent
                            text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                            font.pixelSize: 12
                            font.family: "CaskaydiaCove NF"
                            font.weight: currentConfig.transition === modelData ? Font.Medium : Font.Normal
                            color: currentConfig.transition === modelData ? Theme.onPrimaryContainer : Theme.onSurface

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }

                        MouseArea {
                            id: transitionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: currentConfig.mode === "wallpaper"
                            cursorShape: currentConfig.mode === "wallpaper" ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (currentConfig.mode === "wallpaper") {
                                    callIpc("setTransition", modelData);
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 80
                    height: 80
                    radius: panningMouse.containsMouse ? 40 : 12
                    color: currentConfig.panning ? Theme.primaryContainer : (panningMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                    border.width: currentConfig.panning ? 2 : 1
                    border.color: currentConfig.panning ? Theme.primaryColor : Theme.outlineVariant
                    opacity: currentConfig.mode === "wallpaper" ? 1.0 : 0.3

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }

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

                    Text {
                        anchors.centerIn: parent
                        text: currentConfig.panning ? "Pan On" : "Pan Off"
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        font.weight: currentConfig.panning ? Font.Medium : Font.Normal
                        color: currentConfig.panning ? Theme.onPrimaryContainer : Theme.onSurface

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    MouseArea {
                        id: panningMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: currentConfig.mode === "wallpaper"
                        cursorShape: currentConfig.mode === "wallpaper" ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (currentConfig.mode === "wallpaper") {
                                callIpc("setPanning", currentConfig.panning ? "false" : "true");
                            }
                        }
                    }
                }
            }
        }
    }
}
