import QtQuick
import Qt5Compat.GraphicalEffects
import qs.Services.Theme
import qs.Data
import qs.Components.RoundCorner

Item {
    id: ashRoot
    property bool isHovered: false
    property int customWidth: -1
    property string mode: "circle"

    readonly property int circleSize: 40

    readonly property int defaultWidth: {
        if (mode === "bar" || mode === "notch") {
            return customWidth > 0 ? customWidth : (mode === "bar" ? 1920 : 300);
        }
        return 280;
    }

    readonly property int defaultHeight: {
        if (mode === "bar") {
            return 40;
        }
        if (mode === "notch") {
            return 40;
        }
        return 120;
    }

    readonly property int expandedWidth: defaultWidth

    implicitWidth: {
        if (mode === "bar") {
            return expandedWidth;
        }
        if (mode === "notch") {
            return customWidth > 0 ? customWidth : 300;
        }
        return isHovered ? expandedWidth : circleSize;
    }

    implicitHeight: {
        if (mode === "bar") {
            return defaultHeight;
        }
        if (mode === "notch") {
            return defaultHeight;
        }
        return isHovered ? defaultHeight : circleSize;
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    function saveCurrentConfig() {
        var w = customWidth > 0 ? customWidth : -1;
        AshCallConfig.saveConfig(w, mode);
    }

    Connections {
        target: AshCallConfig

        function onSetWidth(width) {
            if (ashRoot.mode !== "bar" && ashRoot.mode !== "notch") {
                return;
            }
            ashRoot.customWidth = width;
            ashRoot.saveCurrentConfig();
        }

        function onSetMode(newMode) {
            ashRoot.mode = newMode;
            AshCallConfig.currentMode = newMode;
            ashRoot.saveCurrentConfig();
        }

        function onReset() {
            ashRoot.mode = "circle";
            ashRoot.customWidth = -1;
            AshCallConfig.currentMode = "circle";
            ashRoot.saveCurrentConfig();
        }

        function onConfigLoaded(width, loadedMode) {
            ashRoot.mode = loadedMode;
            if (loadedMode === "bar" || loadedMode === "notch") {
                ashRoot.customWidth = width;
            } else {
                ashRoot.customWidth = -1;
            }
        }
    }

    Loader {
        id: circleBarLoader
        anchors.fill: parent
        active: mode !== "notch"

        sourceComponent: Rectangle {
            id: ashContainer
            anchors.fill: parent
            radius: {
                if (mode === "bar") {
                    return 16;
                }
                return ashRoot.isHovered ? 16 : width / 2;
            }
            color: Theme.surfaceContainer
            border.color: Theme.outlineVariant
            border.width: 2
            clip: true

            Behavior on radius {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 300
                }
            }

            HoverHandler {
                id: hoverHandler
                onHoveredChanged: {
                    ashRoot.isHovered = hovered;
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 10
                height: 10
                radius: 5
                color: Theme.primaryColor
                opacity: (mode === "circle" && !ashRoot.isHovered) ? 1 : 0
                visible: mode === "circle" && !ashRoot.isHovered

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 6
                opacity: mode === "bar" ? 1 : (ashRoot.isHovered ? 1 : 0)
                scale: mode === "bar" ? 1 : (ashRoot.isHovered ? 1 : 0.7)
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    text: "Hello Safal,"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Hope you're ok.."
                    font.pixelSize: 14
                    color: Theme.dimColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    Loader {
        id: notchLoader
        anchors.fill: parent
        active: mode === "notch"

        sourceComponent: Item {
            id: notchContainer
            anchors.fill: parent
            clip: true

            readonly property int cornerSize: 25

            Rectangle {
                id: notchBackground
                anchors.fill: parent
                color: Theme.surfaceContainer

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: notchMask
                }
            }

            Item {
                id: notchMask
                anchors.fill: parent
                visible: false
                layer.enabled: true
                layer.smooth: true

                Item {
                    id: leftCornerMaskPart
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: notchContainer.cornerSize
                    height: notchContainer.cornerSize

                    RoundCorner {
                        anchors.fill: parent
                        corner: RoundCorner.CornerEnum.TopRight
                        size: notchContainer.cornerSize
                        color: "white"
                    }
                }

                Rectangle {
                    id: centerMaskPart
                    anchors.top: parent.top
                    anchors.left: leftCornerMaskPart.right
                    anchors.right: rightCornerMaskPart.left
                    height: parent.height
                    color: "white"
                    topLeftRadius: 0
                    topRightRadius: 0
                    bottomLeftRadius: 20
                    bottomRightRadius: 20
                }

                Item {
                    id: rightCornerMaskPart
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: notchContainer.cornerSize
                    height: notchContainer.cornerSize

                    RoundCorner {
                        anchors.fill: parent
                        corner: RoundCorner.CornerEnum.TopLeft
                        size: notchContainer.cornerSize
                        color: "white"
                    }
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "Hello Safal,"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Hope you're ok.."
                    font.pixelSize: 14
                    color: Theme.dimColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
