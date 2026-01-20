import QtQuick

Canvas {
    id: canvas

    property var drawingState: null

    Connections {
        target: drawingState
        function onStateChanged() {
            canvas.requestPaint();
        }
    }

    onPaint: {
        if (!drawingState)
            return;

        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        for (var i = 0; i < drawingState.pathData.length; i++) {
            var path = drawingState.pathData[i];
            drawPath(ctx, path);
        }

        if (drawingState.currentPath.length > 1) {
            drawPath(ctx, {
                points: drawingState.currentPath,
                color: drawingState.drawColor,
                size: drawingState.brushSize,
                type: "pencil"
            });
        }
    }

    function drawPath(ctx, path) {
        if (!path.points || path.points.length < 2) {
            return;
        }

        switch (path.type) {
        case "pencil":
        default:
            drawPencilPath(ctx, path);
            break;
        //future stuff
        }
    }

    function drawPencilPath(ctx, path) {
        ctx.strokeStyle = path.color;
        ctx.lineWidth = path.size;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";

        ctx.beginPath();
        ctx.moveTo(path.points[0].x, path.points[0].y);

        for (var i = 1; i < path.points.length; i++) {
            ctx.lineTo(path.points[i].x, path.points[i].y);
        }

        ctx.stroke();
    }
}
