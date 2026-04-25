pragma ComponentBehavior: Bound
import QtQuick

Canvas {
    id: canvas

    property var drawingState: null

    Connections {
        target: canvas.drawingState
        function onStateChanged() {
            canvas.requestPaint();
        }
    }

    onPaint: {
        if (!canvas.drawingState)
            return;

        const ctx = canvas.getContext("2d");
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        const paths = canvas.drawingState.pathData;
        for (let i = 0; i < paths.length; i++)
            canvas.drawPath(ctx, paths[i]);

        const cur = canvas.drawingState.currentPath;
        if (cur.length > 1) {
            canvas.drawPath(ctx, {
                points: cur,
                color: canvas.drawingState.drawColor,
                size: canvas.drawingState.brushSize,
                type: "pencil"
            });
        }
    }

    function drawPath(ctx, path) {
        if (!path.points || path.points.length < 2)
            return;
        switch (path.type) {
        case "pencil":
        default:
            canvas.drawPencilPath(ctx, path);
            break;
        }
    }

    function drawPencilPath(ctx, path) {
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
