import QtQuick
import "shapes/morph.js" as Morph

Canvas {
    id: root
    property color color: "#685496"
    property var roundedPolygon: null
    property bool polygonIsNormalized: true
    property real borderWidth: 0
    property color borderColor: color
    property bool debug: false
    property real xOffset: 0
    property real yOffset: 0
    property string imageSource: ""

    // Internals: size
    property var bounds: roundedPolygon.calculateBounds()
    implicitWidth: bounds[2] - bounds[0]
    implicitHeight: bounds[3] - bounds[1]

    // Internals: anim
    property var prevRoundedPolygon: null
    property double progress: 1
    property var morph: new Morph.Morph(roundedPolygon, roundedPolygon)
    property Animation animation: NumberAnimation {
        duration: 350
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
    }

    onImageSourceChanged: {
        if (imageSource !== "")
            loadImage(imageSource);
    }

    onImageLoaded: requestPaint()

    onRoundedPolygonChanged: {
        delete root.morph;
        root.morph = new Morph.Morph(root.prevRoundedPolygon ?? root.roundedPolygon, root.roundedPolygon);
        morphBehavior.enabled = false;
        root.progress = 0;
        morphBehavior.enabled = true;
        root.progress = 1;
        root.prevRoundedPolygon = root.roundedPolygon;
    }

    Behavior on progress {
        id: morphBehavior
        animation: root.animation
    }

    onProgressChanged: requestPaint()
    onColorChanged: requestPaint()
    onBorderWidthChanged: requestPaint()
    onBorderColorChanged: requestPaint()
    onDebugChanged: requestPaint()
    onXOffsetChanged: requestPaint()
    onYOffsetChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        if (!root.morph)
            return;
        const cubics = root.morph.asCubics(root.progress);
        if (cubics.length === 0)
            return;
        const size = Math.min(root.width, root.height);

        ctx.save();
        if (root.polygonIsNormalized)
            ctx.scale(size, size);
        ctx.translate(root.xOffset, root.yOffset);

        ctx.beginPath();
        ctx.moveTo(cubics[0].anchor0X, cubics[0].anchor0Y);
        for (const cubic of cubics)
            ctx.bezierCurveTo(cubic.control0X, cubic.control0Y, cubic.control1X, cubic.control1Y, cubic.anchor1X, cubic.anchor1Y);
        ctx.closePath();

        if (root.imageSource !== "" && root.isImageLoaded(root.imageSource)) {
            ctx.restore();
            ctx.save();
            ctx.beginPath();
            ctx.moveTo(cubics[0].anchor0X * size, cubics[0].anchor0Y * size);
            for (const cubic of cubics)
                ctx.bezierCurveTo(cubic.control0X * size, cubic.control0Y * size, cubic.control1X * size, cubic.control1Y * size, cubic.anchor1X * size, cubic.anchor1Y * size);
            ctx.closePath();
            ctx.clip();
            ctx.drawImage(root.imageSource, 0, 0, root.width, root.height);
        } else {
            ctx.fillStyle = root.color;
            ctx.fill();
        }

        if (root.borderWidth > 0) {
            ctx.save();
            ctx.beginPath();
            ctx.moveTo(cubics[0].anchor0X * size, cubics[0].anchor0Y * size);
            for (const cubic of cubics)
                ctx.bezierCurveTo(cubic.control0X * size, cubic.control0Y * size, cubic.control1X * size, cubic.control1Y * size, cubic.anchor1X * size, cubic.anchor1Y * size);
            ctx.closePath();
            ctx.strokeStyle = root.borderColor;
            ctx.lineWidth = root.borderWidth;
            ctx.stroke();
            ctx.restore();
        }

        if (root.debug) {
            const points = [];
            for (let i = 0; i < cubics.length; ++i) {
                const c = cubics[i];
                if (i === 0)
                    points.push({
                        x: c.anchor0X,
                        y: c.anchor0Y
                    });
                points.push({
                    x: c.anchor1X,
                    y: c.anchor1Y
                });
            }
            ctx.fillStyle = "red";
            for (const p of points) {
                ctx.beginPath();
                ctx.arc(p.x, p.y, 2, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        ctx.restore();
    }
}
