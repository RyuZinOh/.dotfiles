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

    property var bounds: roundedPolygon ? roundedPolygon.calculateBounds() : [0, 0, 100, 100]
    implicitWidth: bounds[2] - bounds[0]
    implicitHeight: bounds[3] - bounds[1]

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

        const inset = root.borderWidth / 2;
        const size = Math.min(root.width, root.height) - root.borderWidth;
        const hasImage = root.imageSource !== "" && root.isImageLoaded(root.imageSource);

        function buildPathScaled() {
            ctx.beginPath();
            ctx.moveTo(inset + cubics[0].anchor0X * size, inset + cubics[0].anchor0Y * size);
            for (const cubic of cubics)
                ctx.bezierCurveTo(inset + cubic.control0X * size, inset + cubic.control0Y * size, inset + cubic.control1X * size, inset + cubic.control1Y * size, inset + cubic.anchor1X * size, inset + cubic.anchor1Y * size);
            ctx.closePath();
        }

        if (hasImage) {
            ctx.save();
            buildPathScaled();
            ctx.clip();
            ctx.drawImage(root.imageSource, 0, 0, root.width, root.height);
            ctx.restore();
        } else {
            ctx.save();
            if (root.polygonIsNormalized) {
                ctx.translate(inset, inset);
                ctx.scale(size, size);
            }
            ctx.translate(root.xOffset, root.yOffset);
            ctx.beginPath();
            ctx.moveTo(cubics[0].anchor0X, cubics[0].anchor0Y);
            for (const cubic of cubics)
                ctx.bezierCurveTo(cubic.control0X, cubic.control0Y, cubic.control1X, cubic.control1Y, cubic.anchor1X, cubic.anchor1Y);
            ctx.closePath();
            ctx.fillStyle = root.color;
            ctx.fill();
            ctx.restore();
        }

        if (root.borderWidth > 0) {
            ctx.save();
            buildPathScaled();
            ctx.lineWidth = root.borderWidth;
            ctx.strokeStyle = root.borderColor;
            ctx.lineJoin = "round";
            ctx.lineCap = "round";
            ctx.stroke();
            ctx.restore();
        }

        if (root.debug) {
            ctx.save();
            ctx.fillStyle = "red";
            for (let i = 0; i < cubics.length; ++i) {
                const c = cubics[i];
                if (i === 0) {
                    ctx.beginPath();
                    ctx.arc(inset + c.anchor0X * size, inset + c.anchor0Y * size, 3, 0, Math.PI * 2);
                    ctx.fill();
                }
                ctx.beginPath();
                ctx.arc(inset + c.anchor1X * size, inset + c.anchor1Y * size, 3, 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.restore();
        }
    }
}
