pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import qs.utils

Item {
    id: root

    Pimp {
        id: pimp
    }

    Row {
        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: [{
                "icon": "󱗎",
                "active": DancerConfig.isActive,
                "activeColor": Theme.primaryContainer,
                "activeBorder": Theme.primaryColor,
                "activeText": Theme.onPrimaryContainer,
                "service": "dancer"
            }, {
                "icon": "󰚱",
                "active": OmnitrixConfig.isActive,
                "activeColor": Theme.secondaryContainer,
                "activeBorder": Theme.secondaryColor,
                "activeText": Theme.onSecondaryContainer,
                "service": "omnitrix"
            }, {
                "icon": "✎",
                "active": ArtiqaConfig.isActive,
                "activeColor": Theme.tertiaryContainer,
                "activeBorder": Theme.tertiaryColor,
                "activeText": Theme.onTertiaryContainer,
                "service": "artiqa"
            }]

            delegate: Rectangle {
                id: btn

                required property var modelData
                required property int index

                width: 80
                height: 80
                radius: btnMouse.containsMouse ? 40 : 12
                color: btn.modelData.active ? btn.modelData.activeColor : (btnMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                border.width: btn.modelData.active ? 2 : 1
                border.color: btn.modelData.active ? btn.modelData.activeBorder : Theme.outlineVariant

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

            }

        }

    }

}
