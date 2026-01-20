import QtQuick

QtObject {
    id: drawingState

    property var pathData: []
    property var currentPath: []
    property bool isDrawing: false

    property string drawColor: "#FF3B30"
    property real brushSize: 2.0

    property var undoStack: []

    readonly property bool canUndo: pathData.length > 0
    readonly property bool canRedo: undoStack.length > 0

    signal stateChanged

    function reset() {
        pathData = [];
        currentPath = [];
        undoStack = [];
        isDrawing = false;
        drawColor;
        brushSize = 2.0;
        stateChanged();
    }

    function startPath(point) {
        isDrawing = true;
        currentPath = [point];
    }

    function addPoint(point) {
        if (!isDrawing) {
            return;
        }
        currentPath.push(point);
        stateChanged();
    }

    function finishPath() {
        if (!isDrawing) {
            return;
        }
        isDrawing = false;

        if (currentPath.length > 1) {
            var newPathData = pathData.slice();
            newPathData.push({
                points: currentPath.slice(),
                color: drawColor,
                size: brushSize,
                type: "pencil"
                //other stuffs
            });
            pathData = newPathData;
            undoStack = [];
        }
        currentPath = [];
        stateChanged();
    }

    function undo() {
        if (!canUndo) {
            return;
        }

        var newPathData = pathData.slice();
        var lastPath = newPathData.pop();

        var newUndoStack = undoStack.slice();
        newUndoStack.push(lastPath);

        pathData = newPathData;
        undoStack = newUndoStack;
        stateChanged();
    }

    function redo() {
        if (!canRedo) {
            return;
        }
        var newUndoStack = undoStack.slice();
        var redoPath = newUndoStack.pop();
        var newPathData = pathData.slice();
        newPathData.push(redoPath);
        undoStack = newUndoStack;
        pathData = newPathData;
        stateChanged();
    }
    function clear() {
        pathData = [];
        undoStack = [];
        currentPath = [];
        stateChanged();
    }
}
