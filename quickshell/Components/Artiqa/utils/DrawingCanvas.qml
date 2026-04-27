pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root

    property var drawingState: null

    Canvas {
        id: committedCanvas
        anchors.fill: parent

        property int lastPathCount: -1

        Connections {
            target: root.drawingState
            function onStateChanged() {
                const len = root.drawingState.pathData.length;
                if (len !== committedCanvas.lastPathCount) {
                    committedCanvas.lastPathCount = len;
                    committedCanvas.requestPaint();
                }
            }
        }

        onPaint: {
            if (!root.drawingState)
                return;
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const paths = root.drawingState.pathData;
            for (let i = 0; i < paths.length; i++)
                root.drawPencilPath(ctx, paths[i]);
        }
    }

    Canvas {
        id: liveCanvas
        anchors.fill: parent

        property bool dirty: false

        Connections {
            target: root.drawingState
            function onStateChanged() {
                if (root.drawingState.isDrawing || liveCanvas.dirty)
                    liveCanvas.requestPaint();
            }
        }

        onPaint: {
            if (!root.drawingState)
                return;
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const cur = root.drawingState.currentPath;
            if (cur.length > 1) {
                root.drawPencilPath(ctx, {
                    points: cur,
                    color: root.drawingState.drawColor.toString(),
                    size: root.drawingState.brushSize
                });
                dirty = true;
            } else {
                dirty = false;
            }
        }
    }

    function drawPencilPath(ctx, path) {
        if (!path.points || path.points.length < 2)
            return;
        ctx.strokeStyle = path.color;
        ctx.lineWidth = path.size;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        ctx.beginPath();
        ctx.moveTo(path.points[0].x, path.points[0].y);
        for (let i = 1; i < path.points.length; i++)
            ctx.lineTo(path.points[i].x, path.points[i].y);
        ctx.stroke();
    }
}
