import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Services.Overview

Item {
    id: root
    anchors.fill: parent

    readonly property string surfaceColor: "#100C08"
    readonly property string primaryColor: "#ffffff"
    readonly property string activeWorkspaceColor: "#FFD700"
    readonly property int roundingSmall: 8
    readonly property int roundingNormal: 12

    property bool useScreencopyLivePreview: false

    property int workspacesShown: 10
    property int rows: 2
    property int columns: 5
    property int draggingFromWorkspace: -1
    property int draggingTargetWorkspace: -1
    property real workspaceWidth: 160
    property real workspaceHeight: 90
    property real workspaceSpacing: 8

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
    // getting monitor dimensions
    property var monitorInfo: Hyprland.focusedMonitor
    property real monitorWidth: monitorInfo?.width ?? 1920
    property real monitorHeight: monitorInfo?.height ?? 1080

    // scaling ratios
    readonly property real scaleX: workspaceWidth / monitorWidth
    readonly property real scaleY: workspaceHeight / monitorHeight

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
                        text: root.jpN[parent.workspaceId] ?? parent.workspaceId
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
                id: windowRepeater
                model: HyprlandData.windowList

                Item {
                    id: windowItem
                    required property var modelData
                    required property int index

                    readonly property int workspaceId: modelData.workspace?.id ?? 1
                    readonly property int workspaceIndex: workspaceId - 1
                    readonly property bool isVisible: workspaceIndex >= 0 && workspaceIndex < root.workspacesShown

                    visible: isVisible

                    readonly property int col: workspaceIndex % root.columns
                    readonly property int row: Math.floor(workspaceIndex / root.columns)
                    readonly property real baseX: col * (root.workspaceWidth + root.workspaceSpacing)
                    readonly property real baseY: row * (root.workspaceHeight + root.workspaceSpacing)

                    readonly property real windowX: modelData.at?.[0] ?? 0
                    readonly property real windowY: modelData.at?.[1] ?? 0
                    readonly property real windowWidth: modelData.size?.[0] ?? 100
                    readonly property real windowHeight: modelData.size?.[1] ?? 100

                    readonly property real scaledX: windowX * root.scaleX
                    readonly property real scaledY: windowY * root.scaleY
                    readonly property real scaledW: Math.max(20, windowWidth * root.scaleX)
                    readonly property real scaledH: Math.max(20, windowHeight * root.scaleY)

                    readonly property real clampedW: Math.min(scaledW, root.workspaceWidth - 4)
                    readonly property real clampedH: Math.min(scaledH, root.workspaceHeight - 4)
                    readonly property real clampedX: Math.max(2, Math.min(scaledX, root.workspaceWidth - clampedW - 2))
                    readonly property real clampedY: Math.max(2, Math.min(scaledY, root.workspaceHeight - clampedH - 2))

                    readonly property real targetX: baseX + clampedX
                    readonly property real targetY: baseY + clampedY

                    property bool isDragging: false
                    property bool hovered: false
                    property bool justMoved: false

                    property int prevWorkspaceId: workspaceId

                    onWorkspaceIdChanged: {
                        if (workspaceId !== prevWorkspaceId) {
                            justMoved = true;
                            prevWorkspaceId = workspaceId;
                            settleTimer.restart();
                        }
                    }

                    Timer {
                        id: settleTimer
                        interval: 300
                        onTriggered: {
                            windowItem.justMoved = false;
                        }
                    }

                    x: isDragging ? x : targetX
                    y: isDragging ? y : targetY
                    width: clampedW
                    height: clampedH
                    z: isDragging ? 100 : ((modelData.floating ?? false) ? 2 : 1)

                    Drag.active: dragArea.drag.active
                    Drag.hotSpot.x: width / 2
                    Drag.hotSpot.y: height / 2

                    Rectangle {
                        id: windowRect
                        anchors.fill: parent
                        color: root.surfaceColor
                        radius: 4
                        border.width: 0
                        border.color: "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }

                        Loader {
                            active: root.useScreencopyLivePreview
                            anchors.fill: parent
                            anchors.margins: 1

                            sourceComponent: Component {
                                Repeater {
                                    model: ToplevelManager.toplevels.values

                                    ScreencopyView {
                                        id: screencopy
                                        anchors.fill: parent
                                        captureSource: modelData
                                        layer.enabled: true
                                        layer.smooth: true
                                        visible: `0x${modelData.HyprlandToplevel.address}` === windowItem.modelData.address

                                        Component.onCompleted: {
                                            if (visible) {
                                                updateTimer.start();
                                            }
                                        }

                                        onVisibleChanged: {
                                            if (visible) {
                                                updateTimer.start();
                                            }
                                        }

                                        Timer {
                                            id: updateTimer
                                            interval: 100
                                            repeat: false
                                            onTriggered: {
                                                if (screencopy.visible) {
                                                    screencopy.update();
                                                }
                                            }
                                        }

                                        Connections {
                                            target: windowItem
                                            function onHoveredChanged() {
                                                if (windowItem.hovered && screencopy.visible) {
                                                    updateTimer.restart();
                                                }
                                            }
                                            function onIsDraggingChanged() {
                                                if (windowItem.isDragging && screencopy.visible) {
                                                    updateTimer.restart();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: windowItem.modelData?.class ?? ""
                            color: root.primaryColor
                            font.pixelSize: 9
                            font.weight: Font.Medium
                            visible: parent.width > 50 && parent.height > 30
                            renderType: Text.NativeRendering
                        }
                    }

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        hoverEnabled: root.useScreencopyLivePreview
                        cursorShape: Qt.PointingHandCursor

                        drag.target: parent
                        drag.axis: Drag.XAndYAxis
                        drag.threshold: 4

                        onEntered: {
                            if (root.useScreencopyLivePreview) {
                                windowItem.hovered = true;
                            }
                        }

                        onExited: {
                            if (root.useScreencopyLivePreview) {
                                windowItem.hovered = false;
                            }
                        }

                        onPressed: mouse => {
                            windowItem.isDragging = true;
                            root.draggingFromWorkspace = windowItem.workspaceId;
                            windowItem.Drag.hotSpot.x = mouse.x;
                            windowItem.Drag.hotSpot.y = mouse.y;
                        }

                        onReleased: {
                            const targetWs = root.draggingTargetWorkspace;
                            const fromWs = root.draggingFromWorkspace;

                            windowItem.isDragging = false;
                            root.draggingFromWorkspace = -1;
                            root.draggingTargetWorkspace = -1;

                            if (targetWs !== -1 && targetWs !== fromWs) {
                                Hyprland.dispatch(`movetoworkspacesilent ${targetWs},address:${windowItem.modelData.address}`);
                            } else {
                                windowItem.x = windowItem.targetX;
                                windowItem.y = windowItem.targetY;
                            }
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
                        enabled: !windowItem.isDragging && !windowItem.justMoved
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on height {
                        enabled: !windowItem.isDragging && !windowItem.justMoved
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            const eventName = event.name || "";

            if (eventName === "movewindowv2" || eventName === "changefloatingmode") {
                hyprlandUpdateTimer.restart();
            }
        }
    }

    Timer {
        id: hyprlandUpdateTimer
        interval: 100
        onTriggered: {
            HyprlandData.updateAll();
        }
    }
}
