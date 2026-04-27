import QtQuick
import qs.Services.Theme

QtObject {
    id: drawingState

    property var pathData: []
    property var currentPath: []
    property bool isDrawing: false

    property color drawColor: Theme.errorColor
    property real brushSize: 2.0

    property var undoStack: []

    property bool canUndo: false
    property bool canRedo: false

    signal stateChanged

    function reset() {
        pathData = [];
        currentPath = [];
        undoStack = [];
        isDrawing = false;
        drawColor = Theme.errorColor;
        brushSize = 2.0;
        canUndo = false;
        canRedo = false;
        stateChanged();
    }

    function startPath(point) {
        isDrawing = true;
        currentPath = [point];
    }

    function addPoint(point) {
        if (!isDrawing)
            return;
        currentPath.push(point);
        currentPath = currentPath;
        stateChanged();
    }

    function finishPath() {
        if (!isDrawing)
            return;
        isDrawing = false;
        if (currentPath.length > 1) {
            pathData.push({
                points: currentPath,
                color: drawColor.toString(),
                size: brushSize
            });
            pathData = pathData;
            undoStack = [];
            canUndo = true;
            canRedo = false;
        }
        currentPath = [];
        stateChanged();
    }

    function undo() {
        if (!canUndo)
            return;
        const pd = pathData.slice();
        const us = undoStack.slice();
        us.push(pd.pop());
        pathData = pd;
        undoStack = us;
        canUndo = pd.length > 0;
        canRedo = true;
        stateChanged();
    }

    function redo() {
        if (!canRedo)
            return;
        const pd = pathData.slice();
        const us = undoStack.slice();
        pd.push(us.pop());
        pathData = pd;
        undoStack = us;
        canUndo = true;
        canRedo = us.length > 0;
        stateChanged();
    }

    function clear() {
        pathData = [];
        undoStack = [];
        currentPath = [];
        canUndo = false;
        canRedo = false;
        stateChanged();
    }
}
