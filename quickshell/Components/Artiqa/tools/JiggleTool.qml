import QtQuick
import Quickshell

QtObject {
    id: jiggleTool

    property var drawingState: null
    property var jiggleLayer: null

    function handlePress(mouse) {
        jiggleLayer?.triggerJiggle(mouse.x, mouse.y);
    }

    function handleMove(mouse) {
    }
    function handleRelease(mouse) {
    }

    function activate() {
        if (!jiggleLayer)
            return;
        const screen = Quickshell.screens[0];
        if (screen)
            jiggleLayer.activate(screen);
    }

    function deactivate() {
        jiggleLayer?.deactivate();
    }
}
