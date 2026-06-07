pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Wayland
import qs.Services.Theme
import qs.Configuration.Screenshot

Item {
    id: root
    anchors.fill: parent
    focus: true
    opacity: 0

    required property var screen

    property var points: []
    property bool isDrawing: false

    property real bboxX: 0
    property real bboxY: 0
    property real bboxW: 0
    property real bboxH: 0

    property real lastMouseX: 0
    property real lastMouseY: 0

    Component.onCompleted: {
        root.forceActiveFocus();
        entryAnim.start();
        screencopy.captureFrame();
    }

    Keys.onEscapePressed: ScreenshotConfig.dismiss()

    NumberAnimation {
        id: entryAnim
        target: root
        property: "opacity"
        from: 0
        to: 1
        duration: 180
        easing.type: Easing.OutCubic
    }

    ScreencopyView {
        id: screencopy
        captureSource: root.screen
        live: false
        anchors.fill: parent
    }

    Canvas {
        id: uiCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            ctx.fillStyle = Theme.backgroundColor;
            ctx.globalAlpha = 0.85;
            ctx.fillRect(0, 0, width, height);
            ctx.globalAlpha = 1.0;

            if (root.points.length === 0)
                return;

            ctx.beginPath();
            ctx.moveTo(root.points[0].x, root.points[0].y);
            for (var i = 1; i < root.points.length; i++) {
                ctx.lineTo(root.points[i].x, root.points[i].y);
            }

            if (!root.isDrawing && root.points.length > 2) {
                ctx.closePath();
            }

            if (root.points.length > 2) {
                ctx.save();
                ctx.globalCompositeOperation = "destination-out";
                ctx.fill();
                ctx.restore();
            }

            ctx.strokeStyle = Theme.primaryColor;
            ctx.lineWidth = 3;
            ctx.lineJoin = "round";
            ctx.lineCap = "round";
            ctx.stroke();

            if (root.isDrawing && root.points.length > 1) {
                var lastPoint = root.points[root.points.length - 1];
                var startPoint = root.points[0];

                ctx.beginPath();
                ctx.moveTo(lastPoint.x, lastPoint.y);
                ctx.lineTo(startPoint.x, startPoint.y);
                ctx.strokeStyle = Theme.primaryColor;
                ctx.lineWidth = 2;
                ctx.globalAlpha = 0.4;
                ctx.stroke();
                ctx.globalAlpha = 1.0;

                ctx.beginPath();
                ctx.arc(startPoint.x, startPoint.y, 6, 0, 2 * Math.PI);
                ctx.fillStyle = Theme.primaryColor;
                ctx.fill();
                ctx.lineWidth = 2;
                ctx.strokeStyle = "#FFFFFF";
                ctx.stroke();
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.BlankCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: mouse => {
            if (mouse.button === Qt.RightButton) {
                ScreenshotConfig.dismiss();
                return;
            }
            root.points = [
                {
                    x: mouse.x,
                    y: mouse.y
                }
            ];
            root.isDrawing = true;
            root.lastMouseX = mouse.x;
            root.lastMouseY = mouse.y;
            uiCanvas.requestPaint();
        }

        onPositionChanged: mouse => {
            let mdx = mouse.x - root.lastMouseX;
            let mdy = mouse.y - root.lastMouseY;
            let moveDist = Math.sqrt(mdx * mdx + mdy * mdy);

            if (moveDist > 2) {
                customCursor.targetAngle = (Math.atan2(mdy, mdx) * 180 / Math.PI) + 45;
                root.lastMouseX = mouse.x;
                root.lastMouseY = mouse.y;
            }

            if (root.isDrawing) {
                let lastPoint = root.points[root.points.length - 1];
                let dx = mouse.x - lastPoint.x;
                let dy = mouse.y - lastPoint.y;
                let paintDist = Math.sqrt(dx * dx + dy * dy);

                if (paintDist > 8) {
                    root.points.push({
                        x: mouse.x,
                        y: mouse.y
                    });
                    uiCanvas.requestPaint();
                }
            }
        }

        onReleased: mouse => {
            if (mouse.button === Qt.RightButton)
                return;
            if (root.isDrawing) {
                root.points.push({
                    x: mouse.x,
                    y: mouse.y
                });
                root.isDrawing = false;
                customCursor.targetAngle = 0;
                uiCanvas.requestPaint();

                if (root.points.length < 3) {
                    ScreenshotConfig.dismiss();
                    return;
                }

                let minX = root.width, minY = root.height, maxX = 0, maxY = 0;
                for (let i = 0; i < root.points.length; i++) {
                    let p = root.points[i];
                    if (p.x < minX)
                        minX = p.x;
                    if (p.y < minY)
                        minY = p.y;
                    if (p.x > maxX)
                        maxX = p.x;
                    if (p.y > maxY)
                        maxY = p.y;
                }

                let w = maxX - minX;
                let h = maxY - minY;

                if (w < 8 || h < 8) {
                    ScreenshotConfig.dismiss();
                    return;
                }

                root.bboxX = minX;
                root.bboxY = minY;
                root.bboxW = w;
                root.bboxH = h;

                maskCanvas.requestPaint();

                Qt.callLater(() => {
                    finalComposite.grabToImage(result => {
                        if (!result) {
                            ScreenshotConfig.dismiss();
                            return;
                        }

                        const pngPath = "/tmp/qs_screenshot_lasso_" + Date.now() + ".png";
                        result.saveToFile(pngPath);

                        ScreenshotConfig.lassoPoints = root.points;
                        ScreenshotConfig.previewPath = pngPath;
                        ScreenshotConfig.isPreviewing = true;
                        ScreenshotConfig.captureReady(pngPath);
                        ScreenshotConfig.dismiss();
                    });
                });
            }
        }
    }

    Item {
        id: customCursor
        x: mouseArea.mouseX - width / 2
        y: mouseArea.mouseY - height / 2
        width: 24
        height: 24
        visible: mouseArea.containsMouse
        z: 999

        property real targetAngle: 0

        Behavior on rotation {
            RotationAnimation {
                direction: RotationAnimation.Shortest
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        rotation: targetAngle

        Text {
            text: "\uf0c4"
            font.pixelSize: 24
            font.family: "Font Awesome 6 Free"
            color: Theme.primaryColor
            anchors.centerIn: parent
        }
    }

    Item {
        id: offscreenContainer
        x: root.width * 2
        y: 0
        width: root.bboxW > 0 ? root.bboxW : 1
        height: root.bboxH > 0 ? root.bboxH : 1

        ShaderEffectSource {
            id: cropSource
            sourceItem: screencopy
            sourceRect: Qt.rect(root.bboxX, root.bboxY, root.bboxW, root.bboxH)
            visible: false
        }

        Canvas {
            id: maskCanvas
            width: parent.width
            height: parent.height
            visible: false

            onPaint: {
                if (root.bboxW === 0 || root.bboxH === 0)
                    return;
                var ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = "black";

                ctx.beginPath();
                ctx.moveTo(root.points[0].x - root.bboxX, root.points[0].y - root.bboxY);
                for (var i = 1; i < root.points.length; i++) {
                    ctx.lineTo(root.points[i].x - root.bboxX, root.points[i].y - root.bboxY);
                }
                ctx.closePath();
                ctx.fill();
            }
        }

        MultiEffect {
            id: finalComposite
            anchors.fill: parent
            source: cropSource
            maskSource: maskCanvas
            maskEnabled: true
        }
    }
}
