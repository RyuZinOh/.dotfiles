import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import qs.Services.Theme

Item {
    id: root

    implicitWidth: profileCard.width
    implicitHeight: profileCard.height

    readonly property string pictorialFile: "/home/safal726/.cache/safalQuick/pictorial"

    QtObject {
        id: profileData
        property string pfpPath: ""
    }

    Process {
        id: copyPfpProcess
    }

    Process {
        id: readProcess
        command: ["/usr/bin/sh", "-c", `cat ${pictorialFile} 2>/dev/null | sed "s|^~|$HOME|"`]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const path = data.trim();
                if (path) {
                    profileData.pfpPath = path;
                    const dest = "/home/safal726/.cache/safalQuick/pfp.jpeg";
                    copyPfpProcess.command = ["/usr/bin/sh", "-c", `cp "${path}" "${dest}"`];
                    copyPfpProcess.running = true;
                }
            }
        }
    }

    FileView {
        id: pictorialFileWatcher
        path: "file://" + root.pictorialFile
        blockLoading: true
        watchChanges: true
        onFileChanged: {
            readProcess.running = true;
        }
    }

    Rectangle {
        id: profileCard
        width: profileRow.width + 100
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
                        source: profileData.pfpPath ? "file://" + profileData.pfpPath : ""
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

                    Text {
                        anchors.centerIn: parent
                        text: "󰀄"
                        color: Theme.onSurface
                        font.pixelSize: 28
                        font.family: "CaskaydiaCove NF"
                        visible: !profileData.pfpPath
                        opacity: 0.6
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
