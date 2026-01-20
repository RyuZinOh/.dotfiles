import QtQuick
import qs.Services.Theme
import qs.Components.Artiqa.tools
import qs.Components.Artiqa.utils

Item {
    id: artiqa

    property bool active: false
    visible: active

    property var drawingState: DrawingState {
        id: drawingStateManager
    }

    property var currentTool: pencilTool

    property var pencilTool: PencilTool {
        id: pencilTool
        drawingState: drawingStateManager
    }

    onActiveChanged: {
        if (active) {
            drawingStateManager.reset();
        } else {
            drawingStateManager.reset();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    DrawingCanvas {
        id: canvas
        anchors.fill: parent
        drawingState: drawingStateManager
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.CrossCursor : Qt.ArrowCursor

        onPressed: mouse => {
            if (currentTool) {
                currentTool.handlePress(mouse);
            }
        }

        onPositionChanged: mouse => {
            if (currentTool) {
                currentTool.handleMove(mouse);
            }
        }

        onReleased: mouse => {
            if (currentTool) {
                currentTool.handleRelease(mouse);
            }
        }
    }

    Loader {
        id: toolbarLoader
        active: artiqa.active
        asynchronous: true

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24

        sourceComponent: Rectangle {
            width: 560
            height: 80
            radius: 16
            color: Theme.surfaceContainer
            border.color: Theme.outlineVariant
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 12

                Loader {
                    active: toolbarLoader.active
                    asynchronous: true
                    sourceComponent: ColorSection {
                        currentColor: drawingStateManager.drawColor
                        onColorSelected: color => {
                            drawingStateManager.drawColor = color;
                        }
                    }
                }

                Loader {
                    active: toolbarLoader.active
                    asynchronous: true
                    sourceComponent: SizeSection {
                        currentSize: drawingStateManager.brushSize
                        onSizeSelected: size => {
                            drawingStateManager.brushSize = size;
                        }
                    }
                }

                Loader {
                    active: toolbarLoader.active
                    asynchronous: true
                    sourceComponent: ActionsSection {
                        canUndo: drawingStateManager.canUndo
                        canRedo: drawingStateManager.canRedo

                        onUndoClicked: drawingStateManager.undo()
                        onRedoClicked: drawingStateManager.redo()
                        onClearClicked: drawingStateManager.clear()
                    }
                }
            }
        }
    }
}
