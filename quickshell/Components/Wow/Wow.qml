pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Services.Theme
import qs.Services.Toplevels
import qs.Services.Wow
import qs.utils

Item {
    id: root

    property int workspacesShown: 10
    property int columns: 5
    property int rows: 2
    property real workspaceWidth: 300
    property real workspaceHeight: 166
    property real workspaceSpacing: 14
    property bool previewMode: true
    readonly property var jpN: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

    visible: WowConfig.isActive
    enabled: WowConfig.isActive
    clip: true
    width: (workspaceWidth + workspaceSpacing) * columns - workspaceSpacing
    height: (workspaceHeight + workspaceSpacing) * rows - workspaceSpacing
    anchors.centerIn: parent

    Repeater {
        model: root.workspacesShown

        Item {
            id: workspaceWrapper

            required property int index
            readonly property int workspaceId: index + 1
            readonly property bool isActive: Wow.activeWorkspaceId === workspaceId
            property bool isDropTarget: false
            readonly property HyprlandWorkspace wsp: Hyprland.workspaces.values.find((s) => {
                return s.id === workspaceId;
            }) || null
            readonly property var geo: Wow.workspaceGeometry(wsp)
            readonly property var scale: Wow.scaleFactors(geo, root.workspaceWidth, root.workspaceHeight)
            readonly property var validToplevels: geo.valid

            x: (index % root.columns) * (root.workspaceWidth + root.workspaceSpacing)
            y: Math.floor(index / root.columns) * (root.workspaceHeight + root.workspaceSpacing)
            width: root.workspaceWidth
            height: root.workspaceHeight

            ClippingRectangle {
                anchors.fill: parent
                radius: 12
                color: workspaceWrapper.isDropTarget ? Theme.primaryContainer : workspaceWrapper.isActive ? Theme.surfaceContainerHigh : Theme.surfaceContainer

                Text {
                    anchors.centerIn: parent
                    text: root.jpN[workspaceWrapper.workspaceId - 1] || workspaceWrapper.workspaceId
                    color: Theme.onSurface
                    font.pixelSize: 48
                    font.weight: Font.DemiBold
                    opacity: 0.1
                }

                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 6
                    text: workspaceWrapper.workspaceId
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    opacity: 0.45
                }

                Connections {
                    function onObjectInsertedPre() {
                        Hyprland.refreshToplevels();
                    }

                    function onObjectInsertedPost() {
                        Hyprland.refreshToplevels();
                    }

                    function onObjectRemovedPre() {
                        Hyprland.refreshToplevels();
                    }

                    function onObjectRemovedPost() {
                        Hyprland.refreshToplevels();
                    }

                    target: workspaceWrapper.wsp ? workspaceWrapper.wsp.toplevels : null
                }

                Repeater {
                    model: workspaceWrapper.validToplevels

                    Item {
                        id: windowItem

                        required property HyprlandToplevel modelData
                        readonly property string address: modelData.lastIpcObject.address || ""
                        readonly property var ipc: modelData.lastIpcObject
                        readonly property var rect: Wow.windowCellRect(ipc, workspaceWrapper.geo, workspaceWrapper.scale)
                        property bool isClosing: false
                        property bool isDragging: false

                        x: isDragging ? x : rect.x
                        y: isDragging ? y : rect.y
                        width: rect.w
                        height: rect.h
                        z: isDragging ? 999 : 2
                        opacity: isClosing ? 0 : 1
                        scale: isClosing ? 0.85 : 1
                        onIsClosingChanged: {
                            if (isClosing) {
                                closeTimer.start();
                            }
                        }
                        Drag.active: dragHandler.active
                        Drag.source: windowItem
                        Drag.supportedActions: Qt.MoveAction
                        Drag.hotSpot.x: width / 2
                        Drag.hotSpot.y: height / 2

                        Timer {
                            id: closeTimer

                            interval: 230
                            onTriggered: Hyprland.dispatch("closewindow address:" + windowItem.address)
                        }

                        Loader {
                            anchors.fill: parent
                            active: root.previewMode

                            sourceComponent: ScreencopyView {
                                captureSource: windowItem.modelData ? windowItem.modelData.wayland : null
                                live: true
                                Component.onCompleted: Hyprland.refreshToplevels()
                            }

                        }

                        Item {
                            anchors.fill: parent
                            visible: !root.previewMode

                            Rectangle {
                                anchors.fill: parent
                                color: Theme.surfaceContainerHighest
                                border.width: 0.5
                                border.color: Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.4)
                            }

                            IconImage {
                                property int attempt: 0

                                anchors.centerIn: parent
                                implicitSize: Math.min(windowItem.rect.w, windowItem.rect.h) * 0.2
                                source: Toplevels.iconPath(windowItem.ipc ? windowItem.ipc.class : "", attempt)
                                onStatusChanged: {
                                    var c = Toplevels.iconCandidates(windowItem.ipc ? windowItem.ipc.class : "");
                                    if (status === Image.Error && attempt < c.length - 1)
                                        attempt++;

                                }
                            }

                        }

                        HoverHandler {
                            cursorShape: windowItem.isDragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        }

                        DragHandler {
                            id: dragHandler

                            target: windowItem
                            onActiveChanged: {
                                windowItem.isDragging = active;
                                if (!active) {
                                    var pos = windowItem.mapToItem(root, windowItem.width / 2, windowItem.height / 2);
                                    var outside = pos.x < 0 || pos.x > root.width || pos.y < 0 || pos.y > root.height;
                                    if (outside)
                                        windowItem.isClosing = true;
                                    else
                                        windowItem.Drag.drop();
                                }
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutQuad
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutQuad
                            }

                        }

                        states: State {
                            when: dragHandler.active

                            ParentChange {
                                target: windowItem
                                parent: root
                            }

                        }

                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }

                }

            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: 12
                border.width: (workspaceWrapper.isDropTarget || workspaceWrapper.isActive) ? 2 : 1
                border.color: (workspaceWrapper.isDropTarget || workspaceWrapper.isActive) ? Theme.primaryColor : Qt.rgba(Theme.outlineVariant.r, Theme.outlineVariant.g, Theme.outlineVariant.b, 0.35)

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }

                }

                Behavior on border.width {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }

                }

            }

            DropArea {
                anchors.fill: parent
                onEntered: workspaceWrapper.isDropTarget = true
                onExited: workspaceWrapper.isDropTarget = false
                onDropped: function(drop) {
                    workspaceWrapper.isDropTarget = false;
                    if (drop.source.address) {
                        Hyprland.dispatch("movetoworkspacesilent " + workspaceWrapper.workspaceId + ", address:" + drop.source.address);
                        Hyprland.refreshWorkspaces();
                        Hyprland.refreshMonitors();
                        Hyprland.refreshToplevels();
                    }
                }
            }

        }

    }

}
