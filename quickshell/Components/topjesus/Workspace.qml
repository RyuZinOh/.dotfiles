import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Services.Theme

Item {
    id: root
    //properties
    property int workspaceSize
    property int spacing
    property color activeColor: Theme.primaryColor
    property color occupiedColor: Theme.onSurface
    property bool showNumbers: true
    property color bgOva: "transparent"

    //japanese mapping
    readonly property var jpN: ({
            1: "一",
            2: "二",
            3: "三",
            4: "四",
            5: "五",
            6: "六",
            7: "七",
            8: "八",
            9: "九",
            10: "十"
        })

    //internal
    readonly property var monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? 1
    readonly property var workspaces: {
        var filtered = [];
        for (var i = 1; i <= 10; i++) {
            if (i == root.activeWorkspaceId || root.workspacewithWindows[i]) {
                filtered.push(i);
            }
        }
        return filtered;
    }

    //tracking workspace which has clients
    property var workspacewithWindows: ({})
    property bool componentActive: true

    function updtateWWW() {
        if (!componentActive) {
            return;
        }

        var occupied = {};
        //check clients
        var allWorkspaces = Hyprland.workspaces.values;
        for (var i = 0; i < allWorkspaces.length; i++) {
            var ws = allWorkspaces[i];
            if (ws && ws.id) {
                occupied[ws.id] = true;
            }
        }
        workspacewithWindows = occupied;
    }

    Component.onCompleted: updtateWWW()

    Component.onDestruction: {
        componentActive = false;
    }

    //emit the signal whenever the changes occur
    Connections {
        target: Hyprland.workspaces
        enabled: componentActive
        function onValuesChanged() {
            if (componentActive) {
                updtateWWW();
            }
        }
    }

    Connections {
        target: Hyprland
        enabled: componentActive
        function onFocusedWorkspaceChanged() {
            if (componentActive) {
                updtateWWW();
            }
        }
    }

    implicitWidth: workspaces.length * (workspaceSize + spacing)
    implicitHeight: workspaceSize + spacing
    Rectangle {
        anchors.fill: parent
        color: root.bgOva
    }

    Row {
        anchors.centerIn: parent
        //spacing: root.spacing
        visible: root.showNumbers
        Repeater {
            model: root.workspaces

            Item {
                width: root.workspaceSize
                height: root.workspaceSize

                property bool isHovered: false
                property bool hasWindows: !!root.workspacewithWindows[modelData] //convert to false if undefined with !!
                property bool isActive: modelData === root.activeWorkspaceId

                Text {
                    anchors.centerIn: parent
                    visible: root.showNumbers
                    text: root.jpN[modelData]
                    font.bold: true
                    font.pixelSize: parent.isActive ? 24 : 20
                    color: {
                        if (parent.isHovered) {
                            return root.activeColor;
                        }
                        if (parent.isActive) {
                            return root.activeColor;
                        }
                        if (parent.hasWindows) {
                            return root.occupiedColor;
                        }
                        return root.occupiedColor;
                    }
                    opacity: {
                        if (parent.isHovered) {
                            return 0.85;
                        }
                        if (parent.isActive) {
                            return 1;
                        }
                        if (parent.hasWindows) {
                            return 0.9;
                        }
                        return 0.6;
                    }

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
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData && !parent.isActive) {
                            Hyprland.dispatch("workspace " + modelData); // wow we need space lol
                        }
                    }
                    onEntered: {
                        if (parent)
                            parent.isHovered = true; //checks
                    }
                    onExited: {
                        if (parent) {
                            parent.isHovered = false;
                        }
                    }
                }
            }
        }
    }
}
