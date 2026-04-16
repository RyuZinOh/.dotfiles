pragma ComponentBehavior: Bound
import Cleave
import QtQuick
import qs.Services.Theme
import qs.utils

Item {
    id: root

    property real targetWidth: 1440
    property real targetHeight: 40

    width: targetWidth
    height: targetHeight
    opacity: CleaveConfig.isActive ? 1 : 0

    Cleave {
        id: cleave

        bandCount: 100
        smoothing: 0.1 
        peakDecay: 0.006
        silenceThreshold: 0.0001
        debugMode: false
        onError: (msg) => {
            return console.warn("[CleaveViz]", msg);
        }
    }

    Connections {
        function onActivated() {
            cleave.startCapture();
        }

        function onDeactivated() {
            cleave.stopCapture();
        }

        target: CleaveConfig
    }

    Timer {
        id: decayTimer

        interval: 16
        repeat: true
        running: false
        onTriggered: {
            canvas.requestPaint();
        }
    }

    Canvas {
        id: canvas

        property var smoothed: []
        property real lerpFactor: 0.18

        function allSettled() {
            for (var i = 0; i < smoothed.length; i++) if (smoothed[i] > 0.0001) {
                return false;
            }
            return true;
        }

        function drawWave(ctx, data) {
            var w = width;
            var h = height;
            var n = data.length;
            if (smoothed.length !== n) {
                smoothed = new Array(n);
                for (var s = 0; s < n; s++) smoothed[s] = 0
            }
            for (var t = 0; t < n; t++) smoothed[t] = smoothed[t] + (data[t] - smoothed[t]) * lerpFactor
            if (allSettled()) {
                decayTimer.stop();
                ctx.clearRect(0, 0, w, h);
                return ;
            }
            var peak = 0;
            for (var k = 0; k < n; k++) if (smoothed[k] > peak) {
                peak = smoothed[k];
            }
            var amp = (peak > 0.001) ? (h * 0.92 / peak) : 1;
            var step = w / (n - 1);
            var pts = [];
            for (var i = 0; i < n; i++) pts.push({
                "x": i * step,
                "y": smoothed[i] * amp
            })
            ctx.save();
            ctx.fillStyle = Theme.surfaceContainer;
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(pts[0].x, pts[0].y);
            for (var j = 1; j < n - 1; j++) {
                var cp1x = pts[j - 1].x + (pts[j].x - pts[j - 1].x) * 0.5;
                var cp1y = pts[j - 1].y + (pts[j].y - pts[j - 1].y) * 0.5;
                var cp2x = pts[j].x - (pts[j + 1].x - pts[j - 1].x) * 0.15;
                var cp2y = pts[j].y - (pts[j + 1].y - pts[j - 1].y) * 0.15;
                ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, pts[j].x, pts[j].y);
            }
            ctx.lineTo(pts[n - 1].x, pts[n - 1].y);
            ctx.lineTo(w, 0);
            ctx.closePath();
            ctx.fill();
            ctx.restore();
        }

        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            var rawData = cleave.magnitudes;
            if (!rawData || rawData.length < 2)
                return ;

            var n = rawData.length;
            var processedData = new Array(n);
            for (var i = 0; i < n; i++) {
                var index = (i < n / 2) ? (n / 2 - i) : (i - n / 2);
                processedData[i] = rawData[Math.floor(index)] || 0;
            }
            processedData[0] = 0;
            processedData[n - 1] = 0;
            drawWave(ctx, processedData);
        }

        Connections {
            function onDataChanged() {
                decayTimer.stop();
                canvas.requestPaint();
            }

            target: cleave
        }

        Connections {
            function onSuspendedChanged() {
                if (cleave.suspended)
                    decayTimer.start();

            }

            target: cleave
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 600
            easing.type: Easing.OutCubic
        }

    }

}
