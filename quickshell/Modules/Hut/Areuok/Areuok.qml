pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.Services.Theme
import qs.Services.Shapes

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
            if (root.componentActive)
                root.checkAllServices();
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
        if (!root.componentActive)
            return;
        if (root.activeProcesses[name])
            root.activeProcesses[name].destroy();
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
        spacing: 12
        anchors.centerIn: parent

        Repeater {
            model: [
                {
                    name: "docker",
                    icon: "\uF308",
                    display: "Docker",
                    shapeIdx: 28
                },
                {
                    name: "mariadb",
                    icon: "\ue828",
                    display: "MariaDB",
                    shapeIdx: 13
                },
                {
                    name: "nginx",
                    icon: "\ue776",
                    display: "Nginx",
                    shapeIdx: 14
                },
                {
                    name: "httpd",
                    icon: "\ue72b",
                    display: "Apache",
                    shapeIdx: 22
                }
            ]

            delegate: Item {
                id: chip
                required property var modelData
                required property int index

                width: 56
                height: 56

                readonly property bool running: root.services[chip.modelData.name] === true
                readonly property bool hovered: hoverArea.containsMouse

                property int morphIdx: chip.modelData.shapeIdx

                Timer {
                    interval: 700
                    running: chip.running && !chip.hovered
                    repeat: true
                    onTriggered: chip.morphIdx = (chip.morphIdx + 1) % 35
                }

                onRunningChanged: {
                    if (!chip.running)
                        chip.morphIdx = chip.modelData.shapeIdx;
                }

                ShapeCanvas {
                    anchors.fill: parent
                    roundedPolygon: GetMShapes.get(chip.morphIdx)
                    color: {
                        if (chip.hovered)
                            return chip.running ? Theme.primaryContainer : Theme.errorContainer;
                        return chip.running ? Theme.primaryColor : Theme.surfaceContainerHigh;
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.InOutCubic
                        }
                    }
                    scale: chip.hovered ? 1.08 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 320
                            easing.type: Easing.OutBack
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: chip.modelData.icon
                    font.pixelSize: 22
                    font.family: "CaskaydiaCove NF"
                    color: {
                        if (chip.hovered)
                            return chip.running ? Theme.onPrimaryContainer : Theme.onErrorContainer;
                        return chip.running ? Theme.surfaceContainer : Theme.onSurfaceVariant;
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.InOutCubic
                        }
                    }
                }

                ToolTip {
                    id: tooltip
                    visible: chip.hovered
                    delay: 300
                    text: chip.modelData.display + (chip.running ? " running" : " stopped")
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
