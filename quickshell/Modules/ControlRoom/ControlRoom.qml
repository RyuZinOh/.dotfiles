import QtQuick
import QtQuick.Layouts
import qs.Services.Shapes

Item {
    id: root
    width: content.width
    height: content.height

    property bool isHovered: false
    property real actualHeight: content.height

    Behavior on actualHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    PopoutShape {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        width: 400
        height: root.isHovered ? 240 : 0.1

        style: 1
        alignment: 0
        radius: 20
        color: "black"

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutCubic
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 20
            opacity: root.isHovered ? 1 : 0
            clip: true

            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 12
                RowLayout {
                    spacing: 12
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Behavior on spacing {
                        NumberAnimation {
                            duration: 500
                            easing.type: Easing.InOutCubic
                        }
                    }

                    SystemUsage {
                        type: "memory"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    SystemUsage {
                        type: "cpu"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    SystemUsage {
                        type: "temp"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }

    HoverHandler {
        id: contentHover
        target: content
        onHoveredChanged: root.isHovered = hovered
    }
}
