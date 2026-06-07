pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell.Wayland
import qs.Services.Theme
import qs.Configuration.Screenshot

Item {
    id: root
    anchors.fill: parent
    focus: true
    opacity: 0

    required property var screen

    Component.onCompleted: {
        root.forceActiveFocus();
        entryAnim.start();
        screencopy.captureFrame();
    }

    Keys.onEscapePressed: ScreenshotConfig.dismiss()

    property bool hasDragged: false

    property real ropeDroop: root.hasDragged ? 40 : 140
    Behavior on ropeDroop {
        SpringAnimation {
            spring: 3.0
            damping: 0.4
        }
    }

    property real targetX: root.hasDragged ? Math.min(dragArea.startX, dragArea.curX) : root.width / 2
    property real targetY: root.hasDragged ? Math.min(dragArea.startY, dragArea.curY) : root.height / 2
    property real targetW: root.hasDragged ? Math.abs(dragArea.curX - dragArea.startX) : 0
    property real targetH: root.hasDragged ? Math.abs(dragArea.curY - dragArea.startY) : 0

    property real selX: root.targetX
    property real selY: root.targetY
    property real selW: root.targetW
    property real selH: root.targetH

    Behavior on selX {
        SpringAnimation {
            spring: 4.0
            damping: 0.45
        }
    }
    Behavior on selY {
        SpringAnimation {
            spring: 4.0
            damping: 0.45
        }
    }
    Behavior on selW {
        SpringAnimation {
            spring: 4.0
            damping: 0.45
        }
    }
    Behavior on selH {
        SpringAnimation {
            spring: 4.0
            damping: 0.45
        }
    }

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

    ShaderEffectSource {
        id: cropSource
        sourceItem: screencopy
        live: true
        opacity: 0
    }

    component Overlay: Rectangle {
        color: Theme.backgroundColor
        opacity: 0.85
    }

    component Corner: Rectangle {
        width: 12
        height: 12
        radius: 6
        color: Theme.surfaceColor
        border.color: Theme.primaryColor
        border.width: 2
    }

    Item {
        anchors.fill: parent

        Overlay {
            x: 0
            y: 0
            width: root.width
            height: root.selY
        }
        Overlay {
            x: 0
            y: root.selY
            width: root.selX
            height: root.selH
        }
        Overlay {
            x: root.selX + root.selW
            y: root.selY
            width: root.width - (root.selX + root.selW)
            height: root.selH
        }
        Overlay {
            x: 0
            y: root.selY + root.selH
            width: root.width
            height: root.height - (root.selY + root.selH)
        }

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4
            opacity: 0.7

            ShapePath {
                strokeColor: Theme.primaryColor
                strokeWidth: 2
                fillColor: "transparent"
                startX: 0
                startY: 0
                PathQuad {
                    x: root.selX
                    y: root.selY
                    controlX: root.selX / 2
                    controlY: root.selY / 2 + root.ropeDroop
                }
            }
            ShapePath {
                strokeColor: Theme.primaryColor
                strokeWidth: 2
                fillColor: "transparent"
                startX: root.width
                startY: 0
                PathQuad {
                    x: root.selX + root.selW
                    y: root.selY
                    controlX: (root.width + root.selX + root.selW) / 2
                    controlY: root.selY / 2 + root.ropeDroop
                }
            }
            ShapePath {
                strokeColor: Theme.primaryColor
                strokeWidth: 2
                fillColor: "transparent"
                startX: 0
                startY: root.height
                PathQuad {
                    x: root.selX
                    y: root.selY + root.selH
                    controlX: root.selX / 2
                    controlY: (root.height + root.selY + root.selH) / 2 + root.ropeDroop
                }
            }
            ShapePath {
                strokeColor: Theme.primaryColor
                strokeWidth: 2
                fillColor: "transparent"
                startX: root.width
                startY: root.height
                PathQuad {
                    x: root.selX + root.selW
                    y: root.selY + root.selH
                    controlX: (root.width + root.selX + root.selW) / 2
                    controlY: (root.height + root.selY + root.selH) / 2 + root.ropeDroop
                }
            }
        }

        Rectangle {
            id: cropBoundary
            x: root.selX
            y: root.selY
            width: root.selW
            height: root.selH
            color: "transparent"
            border.color: Theme.primaryColor
            border.width: 2
            opacity: dragArea.isDragging ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutSine
                }
            }

            Corner {
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.top
            }
            Corner {
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.top
            }
            Corner {
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.bottom
            }
            Corner {
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.bottom
            }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        cursorShape: Qt.CrossCursor

        property real startX: 0
        property real startY: 0
        property real curX: 0
        property real curY: 0
        property bool isDragging: false

        onPressed: e => {
            dragArea.startX = e.x;
            dragArea.startY = e.y;
            dragArea.curX = e.x;
            dragArea.curY = e.y;
            dragArea.isDragging = true;
            root.hasDragged = true;
        }
        onPositionChanged: e => {
            if (dragArea.isDragging) {
                dragArea.curX = e.x;
                dragArea.curY = e.y;
            }
        }
        onReleased: e => {
            const x = Math.round(Math.min(dragArea.startX, e.x));
            const y = Math.round(Math.min(dragArea.startY, e.y));
            const w = Math.round(Math.abs(e.x - dragArea.startX));
            const h = Math.round(Math.abs(e.y - dragArea.startY));

            if (w < 8 || h < 8) {
                dragArea.isDragging = false;
                root.hasDragged = false;
                ScreenshotConfig.dismiss();
                return;
            }

            cropSource.sourceRect = Qt.rect(x, y, w, h);
            cropSource.width = w;
            cropSource.height = h;

            cropSource.grabToImage(result => {
                if (!result) {
                    ScreenshotConfig.dismiss();
                    return;
                }

                const bmpPath = "/tmp/qs_screenshot_region_" + Date.now() + ".bmp";
                result.saveToFile(bmpPath);

                ScreenshotConfig.previewPath = bmpPath;
                ScreenshotConfig.isPreviewing = true;
                ScreenshotConfig.captureReady(bmpPath);
                ScreenshotConfig.dismiss();
            });
        }
    }
}
