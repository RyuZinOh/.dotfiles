import QtQuick

QtObject {
    id: pencilTool

    property var drawingState: null

    function handlePress(mouse) {
        if (!drawingState)
            return;
        drawingState.startPath({
            x: mouse.x,
            y: mouse.y
        });
    }

    function handleMove(mouse) {
        if (!drawingState)
            return;
        drawingState.addPoint({
            x: mouse.x,
            y: mouse.y
        });
    }

    function handleRelease(mouse) {
        if (!drawingState)
            return;
        drawingState.finishPath();
    }
}
