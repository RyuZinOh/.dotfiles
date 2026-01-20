import QtQuick
import QtQuick.Layouts
import qs.Services.Theme
import qs.Data

Item {
    id: root

    Pimp {
        id: pimp
    }

    Rectangle {
        anchors.centerIn: parent
        width: 250
        height: 200
        color: Theme.surfaceContainer
        radius: 16
        border.width: 1
        border.color: Theme.outlineVariant

        GridLayout {
            anchors.centerIn: parent
            columns: 2
            rowSpacing: 12
            columnSpacing: 12

            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: dancerMouse.containsMouse ? 40 : 12
                color: DancerConfig.isActive ? Theme.primaryContainer : (dancerMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                border.width: DancerConfig.isActive ? 2 : 1
                border.color: DancerConfig.isActive ? Theme.primaryColor : Theme.outlineVariant

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
                    text: "󱗎"
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 32
                    anchors.centerIn: parent
                    color: DancerConfig.isActive ? Theme.onPrimaryContainer : Theme.onSurface

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                MouseArea {
                    id: dancerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        pimp.call("dancer", DancerConfig.isActive ? "deactivate" : "activate");
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: omnitrixMouse.containsMouse ? 40 : 12
                color: OmnitrixConfig.isActive ? Theme.secondaryContainer : (omnitrixMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                border.width: OmnitrixConfig.isActive ? 2 : 1
                border.color: OmnitrixConfig.isActive ? Theme.secondaryColor : Theme.outlineVariant

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
                    text: "󰚱"
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 32
                    anchors.centerIn: parent
                    color: OmnitrixConfig.isActive ? Theme.onSecondaryContainer : Theme.onSurface

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                MouseArea {
                    id: omnitrixMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        pimp.call("omnitrix", OmnitrixConfig.isActive ? "deactivate" : "activate");
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: artiqaMouse.containsMouse ? 40 : 12
                color: ArtiqaConfig.isActive ? Theme.tertiaryContainer : (artiqaMouse.containsMouse ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow)
                border.width: ArtiqaConfig.isActive ? 2 : 1
                border.color: ArtiqaConfig.isActive ? Theme.tertiaryColor : Theme.outlineVariant

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
                    text: "✎"  // or use "" if you have a nerd font icon
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 32
                    anchors.centerIn: parent
                    color: ArtiqaConfig.isActive ? Theme.onTertiaryContainer : Theme.onSurface

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                MouseArea {
                    id: artiqaMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        pimp.call("artiqa", ArtiqaConfig.isActive ? "deactivate" : "activate");
                    }
                }
            }
        }
    }
}
