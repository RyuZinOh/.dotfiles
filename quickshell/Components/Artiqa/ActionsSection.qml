pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Rectangle {
    id: actionsSection

    property bool canUndo: false
    property bool canRedo: false

    signal undoClicked
    signal redoClicked
    signal clearClicked

    width: 160
    height: 64
    radius: 12
    color: Theme.surfaceContainerLow
    border.color: Theme.outlineVariant
    border.width: 1

    Row {
        anchors.centerIn: parent
        spacing: 8

        Rectangle {
            id: undoBtn

            width: 42
            height: 42
            radius: undoMouse.containsMouse ? 21 : 6
            color: undoMouse.containsMouse ? Theme.secondaryContainer : "transparent"
            border.color: undoMouse.containsMouse ? Theme.secondaryColor : "transparent"
            border.width: undoMouse.containsMouse ? 2 : 0
            scale: undoMouse.pressed ? 0.9 : (undoMouse.containsMouse ? 1.1 : 1.0)
            opacity: actionsSection.canUndo ? 1.0 : 0.3

            Behavior on radius {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutBack
                }
            }

            Text {
                anchors.centerIn: parent
                text: "\uf0e2"
                font.pixelSize: 20
                color: undoMouse.containsMouse ? Theme.onSecondaryContainer : Theme.onSurface
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            MouseArea {
                id: undoMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: actionsSection.canUndo ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (actionsSection.canUndo)
                        actionsSection.undoClicked();
                }
            }
        }

        Rectangle {
            id: redoBtn

            width: 42
            height: 42
            radius: redoMouse.containsMouse ? 21 : 6
            color: redoMouse.containsMouse ? Theme.tertiaryContainer : "transparent"
            border.color: redoMouse.containsMouse ? Theme.tertiaryColor : "transparent"
            border.width: redoMouse.containsMouse ? 2 : 0
            scale: redoMouse.pressed ? 0.9 : (redoMouse.containsMouse ? 1.1 : 1.0)
            opacity: actionsSection.canRedo ? 1.0 : 0.3

            Behavior on radius {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutBack
                }
            }

            Text {
                id: redoIcon
                anchors.centerIn: parent
                text: "\uf0e2"
                font.pixelSize: 20
                color: redoMouse.containsMouse ? Theme.onTertiaryContainer : Theme.onSurface
                transform: Scale {
                    xScale: -1
                    origin.x: redoIcon.width / 2
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            MouseArea {
                id: redoMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: actionsSection.canRedo ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (actionsSection.canRedo)
                        actionsSection.redoClicked();
                }
            }
        }

        Rectangle {
            id: clearBtn

            width: 42
            height: 42
            radius: clearMouse.containsMouse ? 21 : 6
            color: clearMouse.containsMouse ? Theme.errorContainer : "transparent"
            border.color: clearMouse.containsMouse ? Theme.errorColor : "transparent"
            border.width: clearMouse.containsMouse ? 2 : 0
            scale: clearMouse.pressed ? 0.9 : (clearMouse.containsMouse ? 1.1 : 1.0)

            Behavior on radius {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutBack
                }
            }

            Text {
                anchors.centerIn: parent
                text: "\udb81\udfff"
                font.pixelSize: 20
                color: clearMouse.containsMouse ? Theme.onErrorContainer : Theme.onSurface
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            MouseArea {
                id: clearMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: actionsSection.clearClicked()
            }
        }
    }
}
