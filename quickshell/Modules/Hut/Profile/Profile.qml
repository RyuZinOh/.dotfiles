pragma ComponentBehavior: Bound
import QtQuick
import Qt5Compat.GraphicalEffects
import qs.Services.Theme

Item {
    id: root

    implicitWidth: profileCard.width
    implicitHeight: profileCard.height

    Rectangle {
        id: profileCard
        width: profileRow.width  + 80
        height: profileRow.height + 16
        radius: 14
        color: Theme.surfaceContainerHigh
        border.width: 1
        border.color: Theme.outlineVariant

        Row {
            id: profileRow
            anchors.centerIn: parent
            spacing: 12

            Rectangle {
                id: pfpContainer
                width: 100
                height: 100
                radius: width / 2
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                border.width: 2
                border.color: Theme.outlineColor

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: width / 2
                    color: Theme.surfaceContainerHighest
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: "/home/safal726/.cache/safalQuick/pfp.jpeg"
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        cache: false
                        asynchronous: true

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: pfpContainer.width - 4
                                height: pfpContainer.height - 4
                                radius: width / 2
                            }
                        }
                    }
                }
            }

            Text {
                id: greetingText
                anchors.verticalCenter: parent.verticalCenter
                text: "Hey, Safal Lama!"
                color: Theme.onSurface
                font.pixelSize: 15
                font.family: "CaskaydiaCove NF"
                font.weight: Font.Medium
            }
        }
    }
}
