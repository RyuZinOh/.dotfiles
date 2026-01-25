pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.Services.Theme
import qs.utils
import Quickshell

Item {
    id: root

    property var currentConfig: ({
            mode: WallpaperConfig.displayMode,
            transition: WallpaperConfig.transitionType,
            panning: WallpaperConfig.enablePanning
        })

    Connections {
        target: WallpaperConfig

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
        Quickshell.execDetached(["quickshell", "ipc", "call", "wallpaper", method, arg]);
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
                    id: displayRepeater
                    model: ["wallpaper", "minimal", "disabled"]

                    Rectangle {
                        id: displayRect
                        required property string modelData
                        required property int index

                        width: 80
                        height: 80
                        radius: displayMouse.containsMouse ? 40 : 12
                        color: root.currentConfig.mode === displayRect.modelData ? Theme.primaryContainer : (displayMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                        border.width: root.currentConfig.mode === displayRect.modelData ? 2 : 1
                        border.color: root.currentConfig.mode === displayRect.modelData ? Theme.primaryColor : Theme.outlineVariant

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
                            text: displayRect.modelData.charAt(0).toUpperCase() + displayRect.modelData.slice(1)
                            font.pixelSize: 12
                            font.family: "CaskaydiaCove NF"
                            font.weight: root.currentConfig.mode === displayRect.modelData ? Font.Medium : Font.Normal
                            color: root.currentConfig.mode === displayRect.modelData ? Theme.onPrimaryContainer : Theme.onSurface

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
                                root.callIpc("setMode", displayRect.modelData);
                            }
                        }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Repeater {
                    id: transitionRepeater
                    model: ["bubble", "instant"]

                    Rectangle {
                        id: transitionRect
                        required property string modelData
                        required property int index

                        width: 80
                        height: 80
                        radius: transitionMouse.containsMouse ? 40 : 12
                        color: root.currentConfig.transition === transitionRect.modelData ? Theme.primaryContainer : (transitionMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                        border.width: root.currentConfig.transition === transitionRect.modelData ? 2 : 1
                        border.color: root.currentConfig.transition === transitionRect.modelData ? Theme.primaryColor : Theme.outlineVariant
                        opacity: root.currentConfig.mode === "wallpaper" ? 1.0 : 0.3

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
                            text: transitionRect.modelData.charAt(0).toUpperCase() + transitionRect.modelData.slice(1)
                            font.pixelSize: 12
                            font.family: "CaskaydiaCove NF"
                            font.weight: root.currentConfig.transition === transitionRect.modelData ? Font.Medium : Font.Normal
                            color: root.currentConfig.transition === transitionRect.modelData ? Theme.onPrimaryContainer : Theme.onSurface

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
                            enabled: root.currentConfig.mode === "wallpaper"
                            cursorShape: root.currentConfig.mode === "wallpaper" ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (root.currentConfig.mode === "wallpaper") {
                                    root.callIpc("setTransition", transitionRect.modelData);
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: panningRect
                    width: 80
                    height: 80
                    radius: panningMouse.containsMouse ? 40 : 12
                    color: root.currentConfig.panning ? Theme.primaryContainer : (panningMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                    border.width: root.currentConfig.panning ? 2 : 1
                    border.color: root.currentConfig.panning ? Theme.primaryColor : Theme.outlineVariant
                    opacity: root.currentConfig.mode === "wallpaper" ? 1.0 : 0.3

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
                        text: root.currentConfig.panning ? "Pan On" : "Pan Off"
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        font.weight: root.currentConfig.panning ? Font.Medium : Font.Normal
                        color: root.currentConfig.panning ? Theme.onPrimaryContainer : Theme.onSurface

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
                        enabled: root.currentConfig.mode === "wallpaper"
                        cursorShape: root.currentConfig.mode === "wallpaper" ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (root.currentConfig.mode === "wallpaper") {
                                root.callIpc("setPanning", root.currentConfig.panning ? "false" : "true");
                            }
                        }
                    }
                }
            }
        }
    }
}
