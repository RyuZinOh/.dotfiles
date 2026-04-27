pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import "./utils/"
import "./tools/"

Item {
    id: artiqa

    property bool active: false
    property var currentTool: pencilTool

    visible: active

    property var drawingState: DrawingState {
        id: drawingStateManager
    }

    property var pencilTool: PencilTool {
        id: pencilTool
        drawingState: drawingStateManager
    }

    property var jiggleTool: JiggleTool {
        id: jiggleTool
        drawingState: drawingStateManager
        jiggleLayer: jiggleLayer
    }

    readonly property bool isJiggleMode: artiqa.currentTool === jiggleTool

    onActiveChanged: {
        if (!active) {
            if (isJiggleMode) {
                currentTool = pencilTool;
                jiggleTool.deactivate();
            }
            drawingStateManager.clear();
        }
    }

    DrawingCanvas {
        id: canvas
        anchors.fill: parent
        drawingState: artiqa.drawingState
        visible: !artiqa.isJiggleMode
    }

    JiggleLayer {
        id: jiggleLayer
        anchors.fill: parent
        z: 1
    }

    MouseArea {
        anchors.fill: parent
        z: 2
        hoverEnabled: true
        cursorShape: artiqa.isJiggleMode ? Qt.OpenHandCursor : (containsMouse ? Qt.CrossCursor : Qt.ArrowCursor)
        onPressed: mouse => artiqa.currentTool?.handlePress(mouse)
        onPositionChanged: mouse => artiqa.currentTool?.handleMove(mouse)
        onReleased: mouse => artiqa.currentTool?.handleRelease(mouse)
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
        z: 10
        visible: artiqa.active
        width: 620
        height: 80
        radius: 16
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 12

            ColorSection {
                currentColor: artiqa.drawingState.drawColor
                onColorSelected: c => artiqa.drawingState.drawColor = c
                opacity: artiqa.isJiggleMode ? 0.3 : 1.0
                enabled: !artiqa.isJiggleMode
            }

            SizeSection {
                id: sizeSection
                currentSize: artiqa.drawingState.brushSize
                opacity: artiqa.isJiggleMode ? 0.3 : 1.0
                enabled: !artiqa.isJiggleMode
                onSizeSelected: size => {
                    artiqa.drawingState.brushSize = size;
                    sizeDropdownOverlay.visible = false;
                }
                onDropdownToggled: (open, gx, gy) => {
                    if (open) {
                        sizeDropdownOverlay.anchorX = gx;
                        sizeDropdownOverlay.anchorY = gy;
                        sizeDropdownOverlay.visible = true;
                    }
                }
            }

            ActionsSection {
                canUndo: artiqa.drawingState.canUndo
                canRedo: artiqa.drawingState.canRedo
                opacity: artiqa.isJiggleMode ? 0.3 : 1.0
                enabled: !artiqa.isJiggleMode
                onUndoClicked: artiqa.drawingState.undo()
                onRedoClicked: artiqa.drawingState.redo()
                onClearClicked: artiqa.drawingState.clear()
            }

            Rectangle {
                id: jiggleBtn

                width: 52
                height: 52
                radius: jiggleMouse.containsMouse ? 26 : 8
                color: artiqa.isJiggleMode ? Theme.primaryContainer : (jiggleMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent")
                border.color: artiqa.isJiggleMode ? Theme.primaryColor : (jiggleMouse.containsMouse ? Theme.outlineVariant : "transparent")
                border.width: artiqa.isJiggleMode ? 2 : (jiggleMouse.containsMouse ? 1 : 0)
                scale: jiggleMouse.pressed ? 0.9 : (jiggleMouse.containsMouse ? 1.05 : 1.0)

                Behavior on radius {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutBack
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "\ued71"
                    font.pixelSize: 22
                    color: artiqa.isJiggleMode ? Theme.onPrimaryContainer : Theme.onSurface
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    id: jiggleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (artiqa.isJiggleMode) {
                            artiqa.currentTool = artiqa.pencilTool;
                            jiggleTool.deactivate();
                        } else {
                            artiqa.currentTool = artiqa.jiggleTool;
                            jiggleTool.activate();
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: sizeDropdownOverlay

        property real anchorX: 0
        property real anchorY: 0

        visible: false
        z: 20
        x: anchorX - width / 2
        y: anchorY - height - 8
        width: 84
        height: sizeDropdownColumn.implicitHeight + 16
        radius: 12
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1
        opacity: visible ? 1.0 : 0.0
        scale: visible ? 1.0 : 0.95

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }

        Column {
            id: sizeDropdownColumn
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: [2, 4, 6, 8, 10]

                delegate: Rectangle {
                    id: sizeItem
                    required property int modelData

                    width: 68
                    height: 36
                    radius: artiqa.drawingState.brushSize === sizeItem.modelData ? 18 : 8
                    color: artiqa.drawingState.brushSize === sizeItem.modelData ? Theme.primaryContainer : (sizeItemMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent")
                    border.color: artiqa.drawingState.brushSize === sizeItem.modelData ? Theme.primaryColor : (sizeItemMouse.containsMouse ? Theme.outlineVariant : "transparent")
                    border.width: artiqa.drawingState.brushSize === sizeItem.modelData ? 2 : (sizeItemMouse.containsMouse ? 1 : 0)
                    scale: sizeItemMouse.pressed ? 0.95 : (sizeItemMouse.containsMouse ? 1.05 : 1.0)

                    Behavior on radius {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutBack
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: sizeItem.modelData
                        color: artiqa.drawingState.brushSize === sizeItem.modelData ? Theme.onPrimaryContainer : Theme.onSurface
                        font.pixelSize: 18
                        font.weight: artiqa.drawingState.brushSize === sizeItem.modelData ? Font.Bold : Font.Medium
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        id: sizeItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            artiqa.drawingState.brushSize = sizeItem.modelData;
                            sizeDropdownOverlay.visible = false;
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 15
        visible: sizeDropdownOverlay.visible
        onClicked: sizeDropdownOverlay.visible = false
    }
}
