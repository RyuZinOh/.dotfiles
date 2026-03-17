pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property real monitorWidth: Hyprland.focusedMonitor?.width ?? 1920
    readonly property real monitorHeight: Hyprland.focusedMonitor?.height ?? 1080
    readonly property real monitorScale: Hyprland.focusedMonitor?.scale ?? 1
    readonly property int activeWorkspaceId: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1

    function workspaceGeometry(wsp) {
        const monW = wsp?.monitor ? (wsp.monitor.width / wsp.monitor.scale) : (root.monitorWidth / root.monitorScale);
        const monH = wsp?.monitor ? (wsp.monitor.height / wsp.monitor.scale) : (root.monitorHeight / root.monitorScale);
        const monX = wsp?.monitor?.x ?? 0;
        const monY = wsp?.monitor?.y ?? 0;

        const valid = wsp?.toplevels?.values?.filter(t => t.lastIpcObject?.address && t.lastIpcObject?.size?.[0] > 0 && t.lastIpcObject?.size?.[1] > 0) ?? [];

        const minWinX = valid.length > 0 ? valid.reduce((m, t) => Math.min(m, t.lastIpcObject.at?.[0] ?? monX), Infinity) : monX;
        const minWinY = valid.length > 0 ? valid.reduce((m, t) => Math.min(m, t.lastIpcObject.at?.[1] ?? monY), Infinity) : monY;
        const maxWinX = valid.length > 0 ? valid.reduce((m, t) => Math.max(m, (t.lastIpcObject.at?.[0] ?? 0) + (t.lastIpcObject.size?.[0] ?? 0)), 0) : monW;
        const maxWinY = valid.length > 0 ? valid.reduce((m, t) => Math.max(m, (t.lastIpcObject.at?.[1] ?? 0) + (t.lastIpcObject.size?.[1] ?? 0)), 0) : monH;

        const spanW = (maxWinX - minWinX) > 0 ? (maxWinX - minWinX) : monW;
        const spanH = (maxWinY - minWinY) > 0 ? (maxWinY - minWinY) : monH;

        return {
            monW,
            monH,
            monX,
            monY,
            valid,
            minWinX,
            minWinY,
            spanW,
            spanH
        };
    }

    function scaleFactors(geo, cellW, cellH) {
        return {
            x: cellW / geo.spanW,
            y: cellH / geo.spanH
        };
    }

    function windowCellRect(ipc, geo, scale) {
        return {
            x: ((ipc.at?.[0] ?? 0) - geo.minWinX) * scale.x,
            y: ((ipc.at?.[1] ?? 0) - geo.minWinY) * scale.y,
            w: (ipc.size?.[0] ?? 0) * scale.x,
            h: (ipc.size?.[1] ?? 0) * scale.y
        };
    }
}
