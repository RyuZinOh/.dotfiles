import QtQuick
import Quickshell.Hyprland
import qs.Services.Overview

Item {
    id: root
    anchors.fill: parent

    readonly property string surfaceColor: "#100C08"
    readonly property string primaryColor: "#ffffff"
    readonly property string activeWorkspaceColor: "#FFD700"
    readonly property int roundingSmall: 8
    readonly property int roundingNormal: 12

    property int workspacesShown: 10
    property int rows: 2
    property int columns: 5
    property int draggingFromWorkspace: -1
    property int draggingTargetWorkspace: -1
    property real workspaceWidth: 160
    property real workspaceHeight: 90
    property real workspaceSpacing: 8

    // scaling ratios
    readonly property real scaleX: workspaceWidth / 1920
    readonly property real scaleY: workspaceHeight / 1080

    Item {
        anchors.fill: parent
        anchors.margins: 12

        Rectangle {
            anchors.fill: parent
            radius: root.roundingNormal
            color: "transparent"
        }

        Item {
            id: workspaceContainer
            anchors.centerIn: parent
            width: (root.workspaceWidth + root.workspaceSpacing) * root.columns - root.workspaceSpacing
            height: (root.workspaceHeight + root.workspaceSpacing) * root.rows - root.workspaceSpacing

            //Workspaces
            Repeater {
                model: root.workspacesShown

                Rectangle {
                    id: workspaceRect
                    required property int index

                    readonly property int workspaceId: index + 1
                    readonly property int col: index % root.columns
                    readonly property int row: Math.floor(index / root.columns)
                    readonly property bool isActive: Hyprland.focusedMonitor?.activeWorkspace?.id === workspaceId
                    property bool isDropTarget: false

                    x: col * (root.workspaceWidth + root.workspaceSpacing)
                    y: row * (root.workspaceHeight + root.workspaceSpacing)
                    width: root.workspaceWidth
                    height: root.workspaceHeight

                    color: "transparent"
                    radius: root.roundingSmall
                    border.width: isActive ? 3 : (isDropTarget ? 2 : 0)
                    border.color: isActive ? root.activeWorkspaceColor : root.primaryColor

                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parent.workspaceId
                        color: root.primaryColor
                        font.pixelSize: 32
                        font.weight: Font.DemiBold
                    }

                    DropArea {
                        anchors.fill: parent
                        onEntered: {
                            root.draggingTargetWorkspace = parent.workspaceId;
                            if (root.draggingFromWorkspace !== parent.workspaceId) {
                                parent.isDropTarget = true;
                            }
                        }
                        onExited: {
                            parent.isDropTarget = false;
                            if (root.draggingTargetWorkspace === parent.workspaceId) {
                                root.draggingTargetWorkspace = -1;
                            }
                        }
                    }
                }
            }

            //Windows overlay
            Repeater {
                model: HyprlandData.windowList

                Item {
                    id: windowItem
                    required property var modelData

                    readonly property int workspaceId: modelData.workspace?.id ?? 1
                    readonly property int workspaceIndex: workspaceId - 1
                    readonly property bool isVisible: workspaceIndex >= 0 && workspaceIndex < root.workspacesShown

                    visible: isVisible

                    readonly property int col: workspaceIndex % root.columns
                    readonly property int row: Math.floor(workspaceIndex / root.columns)
                    readonly property real baseX: col * (root.workspaceWidth + root.workspaceSpacing)
                    readonly property real baseY: row * (root.workspaceHeight + root.workspaceSpacing)

                    readonly property real scaledX: (modelData.at?.[0] ?? 0) * root.scaleX
                    readonly property real scaledY: (modelData.at?.[1] ?? 0) * root.scaleY
                    readonly property real scaledW: (modelData.size?.[0] ?? 100) * root.scaleX
                    readonly property real scaledH: (modelData.size?.[1] ?? 100) * root.scaleY

                    readonly property real finalW: Math.min(scaledW, root.workspaceWidth - 4)
                    readonly property real finalH: Math.min(scaledH, root.workspaceHeight - 4)
                    readonly property real finalX: baseX + Math.max(2, Math.min(scaledX, root.workspaceWidth - finalW - 2))
                    readonly property real finalY: baseY + Math.max(2, Math.min(scaledY, root.workspaceHeight - finalH - 2))

                    property bool isDragging: false

                    x: finalX
                    y: finalY
                    width: finalW
                    height: finalH
                    z: isDragging ? 100 : ((modelData.floating ?? false) ? 2 : 1)

                    Drag.active: dragArea.drag.active
                    Drag.hotSpot.x: width / 2
                    Drag.hotSpot.y: height / 2

                    Rectangle {
                        anchors.fill: parent
                        color: root.surfaceColor
                        radius: 4
                        border.width: windowItem.isDragging ? 2 : 0
                        border.color: root.primaryColor

                        Text {
                            anchors.centerIn: parent
                            text: windowItem.modelData?.class ?? ""
                            color: root.primaryColor
                            font.pixelSize: 9
                            font.weight: Font.Medium
                            visible: parent.width > 50 && parent.height > 30
                        }
                    }

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        drag.target: parent
                        drag.axis: Drag.XAndYAxis
                        drag.threshold: 4

                        onPressed: mouse => {
                            windowItem.isDragging = true;
                            root.draggingFromWorkspace = windowItem.workspaceId;
                            windowItem.Drag.hotSpot.x = mouse.x;
                            windowItem.Drag.hotSpot.y = mouse.y;
                        }

                        onReleased: {
                            const targetWs = root.draggingTargetWorkspace;
                            const fromWs = root.draggingFromWorkspace;

                            if (targetWs !== -1 && targetWs !== fromWs) {
                                Hyprland.dispatch(`movetoworkspacesilent ${targetWs},address:${windowItem.modelData.address}`);
                                updateTimer.restart();
                            } else {
                                //resets to original position
                                windowItem.x = windowItem.finalX;
                                windowItem.y = windowItem.finalY;
                            }

                            windowItem.isDragging = false;
                            root.draggingFromWorkspace = -1;
                            root.draggingTargetWorkspace = -1;
                        }
                    }

                    Behavior on x {
                        enabled: !windowItem.isDragging
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on y {
                        enabled: !windowItem.isDragging
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on height {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 250
        onTriggered: HyprlandData.updateAll()
    }
}
