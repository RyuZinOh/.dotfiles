pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland
import qs.Services.Theme

Item {
    id: root

    required property var parentScreen

    property int workspaceSize: 0
    property int spacing: 0
    property color activeColor: Theme.primaryColor
    property color occupiedColor: Theme.onSurface
    readonly property var jpN: ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
    readonly property var monitor: Hyprland.monitorFor(root.parentScreen)
    readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? 1
    property var occupiedWorkspaces: new Set()
    readonly property var workspaces: {
        let filtered = [];
        for (let i = 1; i <= 10; i++) {
            if (i === activeWorkspaceId || occupiedWorkspaces.has(i)) {
                filtered.push(i);
            }
        }
        return filtered;
    }
    function updateWorkspaces() {
        let occupied = new Set();
        let allWorkspaces = Hyprland.workspaces.values;
        for (let i = 0; i < allWorkspaces.length; i++) {
            let ws = allWorkspaces[i];
            if (ws?.id)
                occupied.add(ws.id);
        }
        occupiedWorkspaces = occupied;
    }
    Component.onCompleted: root.updateWorkspaces()
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            root.updateWorkspaces();
        }
    }
    implicitWidth: workspaces.length * workspaceSize + Math.max(0, workspaces.length - 1) * spacing
    implicitHeight: workspaceSize
    Row {
        anchors.centerIn: parent
        spacing: root.spacing
        Repeater {
            model: root.workspaces
            Item {
                required property int modelData
                width: root.workspaceSize
                height: root.workspaceSize
                property bool isHovered: false
                property bool hasWindows: root.occupiedWorkspaces.has(modelData)
                property bool isActive: modelData === root.activeWorkspaceId
                Text {
                    anchors.centerIn: parent
                    text: root.jpN[parent.modelData]
                    font.bold: true
                    font.pixelSize: parent.isActive ? 24 : 20
                    color: parent.isActive || parent.isHovered ? root.activeColor : root.occupiedColor
                    opacity: parent.isHovered ? 0.85 : parent.isActive ? 1 : parent.hasWindows ? 0.9 : 0.6
                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!parent.isActive) {
                            Hyprland.dispatch("workspace " + parent.modelData);
                        }
                    }
                    onEntered: parent.isHovered = true
                    onExited: parent.isHovered = false
                }
            }
        }
    }
}
