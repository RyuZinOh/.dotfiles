pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.Services.Theme

Item {
    id: root
    implicitWidth: serviceRow.width
    implicitHeight: 64

    property var services: ({})
    property var activeProcesses: ({})
    property bool componentActive: true

    Component.onCompleted: startupDelay.start()

    Component.onDestruction: {
        root.componentActive = false;
        serviceCheckTimer.running = false;
        Object.keys(root.activeProcesses).forEach(key => {
            if (root.activeProcesses[key])
                root.activeProcesses[key].destroy();
        });
    }

    Timer {
        id: serviceCheckTimer
        interval: 5000
        running: root.componentActive
        repeat: true
        onTriggered: {
            if (root.componentActive) {
                root.checkAllServices();
            }
        }
    }
    Timer {
        id: startupDelay
        interval: 400
        repeat: false
        onTriggered: root.checkAllServices()
    }
    Component {
        id: processComponent
        Process {}
    }

    function checkAllServices() {
        if (!root.componentActive)
            return;
        ["docker", "mariadb", "nginx", "httpd"].forEach(s => root.checkService(s));
    }

    function checkService(name) {
        if (!root.componentActive) {
            return;
        }
        if (root.activeProcesses[name]) {
            root.activeProcesses[name].destroy();
        }
        var proc = processComponent.createObject(root, {
            command: ["systemctl", "is-active", name],
            running: true
        });

        proc.exited.connect(function (code) {
            if (!root.componentActive) {
                proc.destroy();
                return;
            }
            var s = Object.assign({}, root.services);
            s[name] = (code === 0);
            root.services = s;
            proc.destroy();
            delete root.activeProcesses[name];
        });

        root.activeProcesses[name] = proc;
    }

    Row {
        id: serviceRow
        spacing: 16
        anchors.centerIn: parent

        Repeater {
            model: [
                {
                    name: "docker",
                    icon: "\uF308",
                    display: "Docker"
                },
                {
                    name: "mariadb",
                    icon: "\ue828",
                    display: "MariaDB"
                },
                {
                    name: "nginx",
                    icon: "\ue776",
                    display: "Nginx"
                },
                {
                    name: "httpd",
                    icon: "\ue72b",
                    display: "Apache"
                }
            ]

            delegate: Item {
                id: chip
                required property var modelData
                required property int index

                width: 64
                height: 64

                readonly property bool running: root.services[chip.modelData.name] === true
                readonly property bool hovered: hoverArea.containsMouse

                Rectangle {
                    id: orbitRing
                    anchors.centerIn: parent
                    width: 62
                    height: 62
                    radius: 31
                    color: "transparent"
                    border.width: 1.5
                    border.color: chip.running ? Theme.primaryColor : Theme.errorColor
                    opacity: chip.running ? 1.0 : 0.3

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 400
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 400
                        }
                    }

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: Theme.primaryColor
                        visible: chip.running
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: -3
                    }

                    RotationAnimator {
                        target: orbitRing
                        from: 0
                        to: 360
                        duration: 3500
                        loops: Animation.Infinite
                        running: chip.running && !chip.hovered
                        easing.type: Easing.Linear
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 50
                    height: 50
                    radius: 25
                    color: {
                        if (chip.hovered) {
                            return chip.running ? Theme.primaryContainer : Theme.errorContainer;
                        }
                        return Theme.surfaceContainerHigh;
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    scale: chip.hovered ? 1.1 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: chip.modelData.icon || ""
                        font.pixelSize: 22
                        font.family: "CaskaydiaCove NF"
                        color: {
                            if (chip.hovered)
                                return chip.running ? Theme.onPrimaryContainer : Theme.onErrorContainer;
                            return chip.running ? Theme.primaryColor : Theme.onSurfaceVariant;
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }
                }

                ToolTip {
                    id: tooltip
                    visible: chip.hovered
                    delay: 300
                    text: (chip.modelData.display || "") + (chip.running ? " running" : " stopped")
                    background: Rectangle {
                        color: Theme.surfaceContainer
                        radius: 8
                        border.width: 1
                        border.color: Theme.outlineVariant
                    }
                    contentItem: Text {
                        text: tooltip.text
                        color: Theme.onSurface
                        font.pixelSize: 11
                        font.family: "CaskaydiaCove NF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}
