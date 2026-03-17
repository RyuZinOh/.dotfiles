pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Services.Theme
import qs.Services.Toplevels

Item {
    id: root
    visible: Toplevels.model.values.length > 0
    implicitWidth: pill.width
    implicitHeight: pill.height
    property bool barOpen: false

    signal windowHovered(var wayland, real xPos)
    signal windowUnhovered

    Rectangle {
        id: pill
        height: 32
        radius: 8
        width: iconStrip.width + 20
        color: Theme.surfaceContainerHigh
        border.color: Theme.outlineVariant
        border.width: 0.5

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Row {
            id: iconStrip
            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: Toplevels.model
                delegate: Item {
                    id: iconDelegate
                    required property var modelData

                    width: 32
                    height: 28

                    IconImage {
                        id: icon
                        anchors.centerIn: parent
                        implicitSize: 18

                        property int attempt: 0

                        source: Toplevels.iconPath(iconDelegate.modelData.appId, attempt)

                        onStatusChanged: {
                            const candidates = Toplevels.iconCandidates(iconDelegate.modelData.appId);
                            if (status === Image.Error && attempt < candidates.length - 1)
                                attempt++;
                        }
                    }

                    Rectangle {
                        visible: iconDelegate.modelData.activated
                        width: 4
                        height: 4
                        radius: 2
                        color: Theme.primaryColor
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    HoverHandler {
                        enabled: root.barOpen
                        onHoveredChanged: {
                            const hypr = Toplevels.hyprFor(iconDelegate.modelData);
                            if (hovered && hypr?.wayland) {
                                root.windowHovered(hypr.wayland, iconDelegate.mapToItem(root, 0, 0).x + iconDelegate.width / 2);
                            } else {
                                root.windowUnhovered();
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Toplevels.toggleToplevel(iconDelegate.modelData)
                    }
                }
            }
        }
    }
}
