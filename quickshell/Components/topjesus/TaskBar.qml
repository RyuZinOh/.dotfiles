pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import qs.Services.Theme
import qs.Services.Toplevels

Item {
    id: root

    // property bool barOpen: false

    // signal windowHovered(var wayland, real xPos)
    // signal windowUnhovered

    visible: Toplevels.enriched.length > 0
    implicitWidth: visible ? pill.width : 0
    implicitHeight: visible ? pill.height : 0

    Rectangle {
        id: pill

        height: 32
        radius: 8
        width: iconStrip.implicitWidth + 20
        color: Theme.surfaceContainerHigh
        border.color: Theme.outlineVariant
        border.width: 0.5

        Row {
            id: iconStrip

            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: Toplevels.enriched

                delegate: Item {
                    id: iconDelegate

                    required property var modelData

                    width: 32
                    height: 28

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 18
                        source: iconDelegate.modelData.icon
                    }

                    Rectangle {
                        visible: iconDelegate.modelData.toplevel.activated
                        width: 4
                        height: 4
                        radius: 2
                        color: Theme.primaryColor
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
