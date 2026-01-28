pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import qs.Services.Overview

Item {
    id: root

    property int workspacesShown: 10
    property int columns: 5
    property int rows: 2
    property real workspaceWidth: 260
    property real workspaceHeight: 150
    property real workspaceSpacing: 14

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

    HyprlandData {
        id: hyprlandData
    }

    // getting monitor dimensions
    property var monitorInfo: hyprlandData.focusedMonitor
    property real monitorWidth: monitorInfo?.width ?? 1920
    property real monitorHeight: monitorInfo?.height ?? 1080

    // scaling ratios
    readonly property real scaleX: workspaceWidth / monitorWidth
    readonly property real scaleY: workspaceHeight / monitorHeight

    property int draggingFromWorkspace: -1
    property int draggingTargetWorkspace: -1
    property bool isDraggingToClose: false

    property int activeWorkspaceId: hyprlandData.activeWorkspaceId ?? 1

    Connections {
        target: hyprlandData
        function onActiveWorkspaceIdChanged() {
            root.activeWorkspaceId = hyprlandData.activeWorkspaceId;
        }
    }

    Component.onCompleted: {
        activeWorkspaceId = hyprlandData.activeWorkspaceId ?? 1;
    }

    Item {
        id: workspaceContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: (root.workspaceWidth + root.workspaceSpacing) * root.columns - root.workspaceSpacing
        height: (root.workspaceHeight + root.workspaceSpacing) * root.rows - root.workspaceSpacing

        //Windows overlay
        Repeater {
            model: root.workspacesShown

            Rectangle {
                id: workspaceRect
                required property int index

                readonly property int workspaceId: workspaceRect.index + 1
                readonly property int col: workspaceRect.index % root.columns
                readonly property int row: Math.floor(workspaceRect.index / root.columns)
                readonly property bool isActive: root.activeWorkspaceId === workspaceRect.workspaceId
                property bool isDropTarget: false

                x: workspaceRect.col * (root.workspaceWidth + root.workspaceSpacing)
                y: workspaceRect.row * (root.workspaceHeight + root.workspaceSpacing)
                width: root.workspaceWidth
                height: root.workspaceHeight

                color: workspaceRect.isActive ? Theme.surfaceContainerHigh : Theme.surfaceContainer
                radius: 12
                border.width: workspaceRect.isActive ? 2 : 0
                border.color: workspaceRect.isActive ? Theme.primaryColor : "transparent"
                clip: true

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on border.width {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.jpN[workspaceRect.workspaceId] ?? workspaceRect.workspaceId
                    color: Theme.onSurface
                    font.pixelSize: 36
                    font.weight: Font.DemiBold
                    opacity: 0.15
                }

                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 10
                    text: workspaceRect.workspaceId
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    opacity: 0.4
                }

                Rectangle {
                    anchors.fill: parent
                    radius: workspaceRect.radius
                    color: "transparent"
                    border.width: workspaceRect.isDropTarget ? 3 : 0
                    border.color: Theme.primaryColor
                    opacity: 0.8
                    visible: workspaceRect.isDropTarget

                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                DropArea {
                    anchors.fill: parent
                    onEntered: {
                        root.draggingTargetWorkspace = workspaceRect.workspaceId;
                        root.isDraggingToClose = false;
                        if (root.draggingFromWorkspace !== workspaceRect.workspaceId) {
                            workspaceRect.isDropTarget = true;
                        }
                    }
                    onExited: {
                        workspaceRect.isDropTarget = false;
                        if (root.draggingTargetWorkspace === workspaceRect.workspaceId) {
                            root.draggingTargetWorkspace = -1;
                        }
                    }
                }
                // MouseArea {
                //     anchors.fill: parent
                //     cursorShape: Qt.PointingHandCursor
                //     onClicked: {
                //         hyprlandData.dispatch(`workspace ${workspaceRect.workspaceId}`);
                //     }
                // }
            }
        }

        Repeater {
            model: hyprlandData.windowList

            Item {
                id: windowItem
                required property var modelData
                required property int index

                readonly property int workspaceId: windowItem.modelData.workspace?.id ?? 1
                readonly property int workspaceIndex: windowItem.workspaceId - 1
                readonly property bool isVisible: windowItem.workspaceIndex >= 0 && windowItem.workspaceIndex < root.workspacesShown

                visible: windowItem.isVisible

                readonly property int col: windowItem.workspaceIndex % root.columns
                readonly property int row: Math.floor(windowItem.workspaceIndex / root.columns)
                readonly property real baseX: windowItem.col * (root.workspaceWidth + root.workspaceSpacing)
                readonly property real baseY: windowItem.row * (root.workspaceHeight + root.workspaceSpacing)

                readonly property var atArray: windowItem.modelData.at ?? [0, 0]
                readonly property var sizeArray: windowItem.modelData.size ?? [100, 100]

                readonly property real windowX: windowItem.atArray[0] ?? 0
                readonly property real windowY: windowItem.atArray[1] ?? 0
                readonly property real windowWidth: windowItem.sizeArray[0] ?? 100
                readonly property real windowHeight: windowItem.sizeArray[1] ?? 100

                readonly property real scaledX: windowItem.windowX * root.scaleX
                readonly property real scaledY: windowItem.windowY * root.scaleY
                readonly property real scaledW: Math.max(20, windowItem.windowWidth * root.scaleX)
                readonly property real scaledH: Math.max(20, windowItem.windowHeight * root.scaleY)

                readonly property bool isActiveWorkspace: root.activeWorkspaceId === windowItem.workspaceId
                readonly property real borderWidth: windowItem.isActiveWorkspace ? 2 : 0
                readonly property real contentPadding: windowItem.borderWidth + 4

                readonly property real clampedW: Math.min(windowItem.scaledW, root.workspaceWidth - (windowItem.contentPadding * 2))
                readonly property real clampedH: Math.min(windowItem.scaledH, root.workspaceHeight - (windowItem.contentPadding * 2))
                readonly property real clampedX: Math.max(windowItem.contentPadding, Math.min(windowItem.scaledX + windowItem.contentPadding, root.workspaceWidth - windowItem.clampedW - windowItem.contentPadding))
                readonly property real clampedY: Math.max(windowItem.contentPadding, Math.min(windowItem.scaledY + windowItem.contentPadding, root.workspaceHeight - windowItem.clampedH - windowItem.contentPadding))

                readonly property real targetX: windowItem.baseX + windowItem.clampedX
                readonly property real targetY: windowItem.baseY + windowItem.clampedY

                property bool isDragging: false
                property bool hovered: false

                x: windowItem.targetX
                y: windowItem.targetY
                width: windowItem.clampedW
                height: windowItem.clampedH
                z: windowItem.isDragging ? 100 : ((windowItem.modelData.floating ?? false) ? 2 : 1)

                Drag.active: dragArea.drag.active
                Drag.hotSpot.x: width / 2
                Drag.hotSpot.y: height / 2

                Rectangle {
                    id: windowBackground
                    anchors.fill: parent
                    color: windowItem.hovered ? Theme.surfaceContainerHigh : Theme.surfaceContainerHighest
                    radius: 8
                    border.width: windowItem.isDragging ? 2 : 0
                    border.color: root.isDraggingToClose ? Theme.errorColor : Theme.primaryColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }

                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: windowItem.modelData?.class ?? "Window"
                        color: Theme.onSurface
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        elide: Text.ElideMiddle
                        width: Math.min(implicitWidth, windowItem.width - 20)
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: windowBackground.radius
                    color: root.isDraggingToClose && windowItem.isDragging ? Theme.errorColor : Theme.primaryColor
                    opacity: root.isDraggingToClose && windowItem.isDragging ? 0.15 : (windowItem.hovered && !windowItem.isDragging ? 0.12 : 0)

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: pressed ? Qt.ClosedHandCursor : (containsMouse ? Qt.OpenHandCursor : Qt.ArrowCursor)

                    drag.target: windowItem
                    drag.axis: Drag.XAndYAxis
                    drag.threshold: 4

                    property bool wasDragging: false

                    onEntered: windowItem.hovered = true
                    onExited: windowItem.hovered = false

                    onPressed: mouse => {
                        dragArea.wasDragging = false;
                        windowItem.isDragging = true;
                        root.draggingFromWorkspace = windowItem.workspaceId;
                        windowItem.Drag.hotSpot.x = mouse.x;
                        windowItem.Drag.hotSpot.y = mouse.y;
                    }

                    onPositionChanged: {
                        if (windowItem.isDragging) {
                            dragArea.wasDragging = true;

                            const globalPos = windowItem.mapToItem(workspaceContainer, windowItem.width / 2, windowItem.height / 2);
                            const isOutside = globalPos.x < 0 || globalPos.x > workspaceContainer.width || globalPos.y < 0 || globalPos.y > workspaceContainer.height;

                            if (isOutside && root.draggingTargetWorkspace === -1) {
                                root.isDraggingToClose = true;
                            } else {
                                root.isDraggingToClose = false;
                            }
                        }
                    }

                    onReleased: {
                        const targetWs = root.draggingTargetWorkspace;
                        const fromWs = root.draggingFromWorkspace;
                        const shouldClose = root.isDraggingToClose;

                        windowItem.isDragging = false;
                        root.draggingFromWorkspace = -1;
                        root.draggingTargetWorkspace = -1;
                        root.isDraggingToClose = false;

                        if (shouldClose && dragArea.wasDragging) {
                            hyprlandData.dispatch(`closewindow address:${windowItem.modelData.address}`);
                        } else if (targetWs !== -1 && targetWs !== fromWs && dragArea.wasDragging) {
                            hyprlandData.dispatch(`movetoworkspacesilent ${targetWs},address:${windowItem.modelData.address}`);
                        } else {
                            windowItem.x = windowItem.targetX;
                            windowItem.y = windowItem.targetY;
                        }

                        dragArea.wasDragging = false;
                    }

                    // onClicked: {
                    //     if (!dragArea.wasDragging) {
                    //         // hyprlandData.dispatch(`focuswindow address:${windowItem.modelData.address}`);
                    //     }
                    // }
                }

                Behavior on x {
                    enabled: !windowItem.isDragging
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on y {
                    enabled: !windowItem.isDragging
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on width {
                    enabled: !windowItem.isDragging
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    enabled: !windowItem.isDragging
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
