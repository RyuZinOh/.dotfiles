import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.Services.Theme

Item {
    id: root
    implicitWidth: serviceRow.width
    implicitHeight: 50

    property var services: ({})
    property var activeProcesses: ({})
    property bool componentActive: true

    Component.onCompleted: checkAllServices()

    Component.onDestruction: {
        componentActive = false;
        serviceCheckTimer.running = false;
        Object.keys(activeProcesses).forEach(key => {
            if (activeProcesses[key])
                activeProcesses[key].destroy();
        });
    }

    Timer {
        id: serviceCheckTimer
        interval: 5000
        running: componentActive
        repeat: true
        onTriggered: {
            if (componentActive) {
                checkAllServices();
            }
        }
    }

    Component {
        id: processComponent
        Process {}
    }

    function checkAllServices() {
        if (!componentActive)
            return;
        ["docker", "mariadb", "nginx", "httpd"].forEach(service => {
            checkService(service);
        });
    }

    function checkService(name) {
        if (!componentActive)
            return;

        if (activeProcesses[name])
            activeProcesses[name].destroy();

        var proc = processComponent.createObject(root, {
            command: ["systemctl", "is-active", name],
            running: true
        });

        proc.exited.connect(function (code) {
            if (!componentActive) {
                proc.destroy();
                return;
            }
            var newServices = Object.assign({}, services);
            newServices[name] = (code === 0);
            services = newServices;
            proc.destroy();
            delete activeProcesses[name];
        });

        activeProcesses[name] = proc;
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

            Rectangle {
                width: 70
                height: 40
                radius: mouseArea.containsMouse ? 20 : 10

                color: {
                    var running = services[modelData.name] === true;
                    if (mouseArea.containsMouse)
                        return running ? Theme.primaryContainer : Theme.errorContainer;
                    return running ? Theme.surfaceContainerHigh : Theme.surfaceContainerHighest;
                }

                border.width: 1
                border.color: {
                    var running = services[modelData.name] === true;
                    return running ? Theme.primaryColor : Theme.errorColor;
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

                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon || ""
                    font.pixelSize: 20
                    font.family: "0xProto Nerd Font"
                    color: {
                        var running = services[modelData.name] === true;
                        if (mouseArea.containsMouse)
                            return running ? Theme.onPrimaryContainer : Theme.onErrorContainer;
                        return Theme.onSurface;
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                ToolTip {
                    id: tooltip
                    visible: mouseArea.containsMouse
                    delay: 150
                    text: {
                        var running = services[modelData.name] === true;
                        return (modelData.display || "") + (running ? " is running" : " is not running");
                    }

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
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}
