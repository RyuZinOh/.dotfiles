pragma ComponentBehavior: Bound
import QtQuick
/* plugin custom
 https://github.com/Happilli/HyprlandMonitor
 */
import HyprlandMonitor

Item {
    id: root

    property alias windowList: monitor.windowList
    property alias workspaces: monitor.workspaces
    property alias monitors: monitor.monitors
    property alias activeWorkspace: monitor.activeWorkspace
    property alias activeWorkspaceId: monitor.activeWorkspaceId
    property alias focusedMonitor: monitor.focusedMonitor
    property alias connected: monitor.connected
    property alias windowByAddressMap: monitor.windowByAddressMap
    property alias workspaceByIdMap: monitor.workspaceByIdMap
    property alias workspaceIds: monitor.workspaceIds
    property alias addresses: monitor.addresses

    // Various calls
    function refresh() {
        monitor.refresh();
    }

    function updateWindowList() {
        monitor.refresh();
    }

    function updateMonitors() {
        monitor.refresh();
    }

    function updateWorkspaces() {
        monitor.refresh();
    }

    function updateAll() {
        monitor.refresh();
    }

    function windowByAddress(address) {
        return monitor.windowByAddress(address);
    }

    function workspaceById(id) {
        return monitor.workspaceById(id);
    }

    function biggestWindowForWorkspace(workspaceId) {
        return monitor.biggestWindowForWorkspace(workspaceId);
    }

    function dispatch(command) {
        monitor.dispatch(command);
    }

    property HyprlandMonitor monitor: HyprlandMonitor {
        id: monitor
        Component.onCompleted: refresh()
    }
}
