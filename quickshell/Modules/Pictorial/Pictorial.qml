import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import qs.Services.Shapes
import Quickshell.Io

Item {
    id: root
    width: content.width
    height: 300
    property bool isHovered: false

    readonly property string pictorialFile: "/home/safal726/.cache/safalQuick/pictorial"

    // profile datas
    QtObject {
        id: profileData
        property string pfpPath: ""
        property string name: "Safal Lama"
    }

    //applications
    property var appLaunchers: [
        {
            icon: "󰨞",
            name: "VSCodium",
            command: ["codium"]
        },
        {
            icon: "󰻀",
            name: "Qemu",
            command: ["virt-manager"]
        }
    ]

    // launch apps
    function launchApp(command) {
        launcher.command = command;
        launcher.running = true;
    }

    // reusable process launcher [at a time workspace only]
    Process {
        id: launcher
    }
    Process {
        id: copyPfpProcess
    }
    //read the cache
    Process {
        id: readProcess
        command: ["/usr/bin/sh", "-c", `cat ${pictorialFile} 2>/dev/null | sed "s|^~|$HOME|"`]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const path = data.trim();
                if (path) {
                    profileData.pfpPath = path;
                    // copies pfp into hyprlock folder
                    const dest = "/home/safal726/.cache/hyprlock-safal/pfp.jpeg";
                    copyPfpProcess.command = ["/usr/bin/sh", "-c", `cp "${path}" "${dest}"`];
                    copyPfpProcess.running = true;
                }
            }
        }
    }

    PopoutShape {
        id: content
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: root.isHovered ? 200 : 0.1
        height: root.isHovered ? parent.height : 0.1
        style: 1
        alignment: 3
        radius: 20
        color: "black"

        Behavior on width {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutCubic
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 24
            opacity: root.isHovered ? 1 : 0
            visible: opacity > 0
            scale: root.isHovered ? 1 : 0.85

            Behavior on opacity {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 450
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width
                spacing: 16

                // Pfp with reload button overlay
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 95
                    Layout.preferredHeight: 95

                    Rectangle {
                        id: pfpContainer
                        anchors.fill: parent
                        radius: width / 2
                        color: "white"
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 3
                            source: profileData.pfpPath ? "file://" + profileData.pfpPath : ""
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            cache: false
                            asynchronous: true

                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: pfpContainer.width - 6
                                    height: pfpContainer.height - 6
                                    radius: width / 2
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰀄"
                            color: "white"
                            font.pixelSize: 56
                            font.family: "CaskaydiaCove NF"
                            visible: !profileData.pfpPath
                        }
                    }

                    // Reload button
                    Rectangle {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        width: 28
                        height: 28
                        radius: width / 2
                        color: reloadButton.containsMouse ? "#2B2B2B" : "black"

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            color: "white"
                            font.pixelSize: 16
                            font.family: "CaskaydiaCove NF"

                            RotationAnimator on rotation {
                                id: spinAnimation
                                from: 0
                                to: 360
                                duration: 600
                                running: false
                                loops: 1
                            }
                        }

                        MouseArea {
                            id: reloadButton
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                spinAnimation.start();
                                readProcess.running = true;
                            }
                        }
                    }
                }

                // name
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: profileData.name
                    color: "white"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    font.family: "CaskaydiaCove NF"
                }

                // app Icons Row
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Repeater {
                        model: root.appLaunchers

                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: 100
                            color: appMouse.containsMouse ? "#2B1B1B" : "#1B1212"

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: "white"
                                font.pixelSize: 32
                                font.family: "CaskaydiaCove NF"
                            }

                            MouseArea {
                                id: appMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: root.launchApp(modelData.command)
                            }

                            // tooltip
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.top
                                anchors.bottomMargin: 8
                                width: tooltipText.width + 16
                                height: 24
                                radius: 4
                                color: "black"
                                visible: appMouse.containsMouse
                                opacity: 0.95

                                Text {
                                    id: tooltipText
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: "white"
                                    font.pixelSize: 12
                                    font.family: "CaskaydiaCove NF"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: root.isHovered = hovered
    }
}
