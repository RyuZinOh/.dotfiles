pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Services.Theme
import qs.utils

Item {
    id: root

    Pimp {
        id: pimp
    }

    Rectangle {
        anchors.centerIn: parent
        width: grid.width + 24
        height: grid.height + 24
        color: "transparent"
        radius: 16
        border.width: 1
        border.color: Theme.outlineVariant
    }

    GridLayout {
        id: grid
        anchors.centerIn: parent
        columns: 2
        rowSpacing: 12
        columnSpacing: 12

        Repeater {
            model: [
                {
                    icon: "󱗎",
                    active: DancerConfig.isActive,
                    activeColor: Theme.primaryContainer,
                    activeBorder: Theme.primaryColor,
                    activeText: Theme.onPrimaryContainer,
                    service: "dancer"
                },
                {
                    icon: "󰚱",
                    active: OmnitrixConfig.isActive,
                    activeColor: Theme.secondaryContainer,
                    activeBorder: Theme.secondaryColor,
                    activeText: Theme.onSecondaryContainer,
                    service: "omnitrix"
                },
                {
                    icon: "✎",
                    active: ArtiqaConfig.isActive,
                    activeColor: Theme.tertiaryContainer,
                    activeBorder: Theme.tertiaryColor,
                    activeText: Theme.onTertiaryContainer,
                    service: "artiqa"
                },
                {
                    icon: "󰄛",
                    active: PoketwoConfig.isActive,
                    activeColor: Theme.primaryContainer,
                    activeBorder: Theme.primaryColor,
                    activeText: Theme.onPrimaryContainer,
                    service: "poketwo"
                },
            ]

            delegate: Rectangle {
                id: btn
                required property var modelData
                required property int index

                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: btnMouse.containsMouse ? 40 : 12
                color: btn.modelData.active ? btn.modelData.activeColor : (btnMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                border.width: btn.modelData.active ? 2 : 1
                border.color: btn.modelData.active ? btn.modelData.activeBorder : Theme.outlineVariant

                Behavior on radius {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on border.width {
                    NumberAnimation {
                        duration: 200
                    }
                }
                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                Text {
                    text: btn.modelData.icon
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 32
                    anchors.centerIn: parent
                    color: btn.modelData.active ? btn.modelData.activeText : Theme.onSurface
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pimp.call(btn.modelData.service, btn.modelData.active ? "deactivate" : "activate")
                }
            }
        }
    }
}
