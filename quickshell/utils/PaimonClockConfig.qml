pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.Paths

Singleton {
    id: root

    property bool isActive: false
    property real clockX: 0
    property real clockY: 0

    property real screenWidth: 0
    property real screenHeight: 0
    property real clockWidth: 0
    property real clockHeight: 0

    signal showPaimonClock
    signal hidePaimonClock

    readonly property string statePath: PathService.state + "/paimonclockstate.json"

    property var _view: FileView {
        path: root.statePath
        watchChanges: false
        onLoaded: {
            try {
                const parsed = JSON.parse(text());
                if (parsed && typeof parsed === "object") {
                    root.isActive = parsed.isActive ?? false;
                    root.clockX = parsed.clockX ?? 0;
                    root.clockY = parsed.clockY ?? 0;
                }
            } catch (e) {
                console.warn("PaimonClockConfig: parse failed —", e);
            }
        }
        onLoadFailed: _ => {}
    }

    function _save() {
        _view.setText(JSON.stringify({
            isActive: root.isActive,
            clockX: root.clockX,
            clockY: root.clockY
        }, null, 2));
    }

    function randomizePosition() {
        if (!root.isActive) {
            return;
        }
        // clamp to screen bounds so clock never spawns partially off-screen
        root.clockX = Math.floor(Math.random() * Math.max(0, root.screenWidth - root.clockWidth));
        root.clockY = Math.floor(Math.random() * Math.max(0, root.screenHeight * 0.5 - root.clockHeight));
        _save();
    }

    function show() {
        root.isActive = true;
        _save();
        root.showPaimonClock();
    }

    function hide() {
        root.isActive = false;
        _save();
        root.hidePaimonClock();
    }

    function toggle() {
        if (root.isActive)
            hide();
        else
            show();
    }

    Component.onCompleted: _view.reload()
}
