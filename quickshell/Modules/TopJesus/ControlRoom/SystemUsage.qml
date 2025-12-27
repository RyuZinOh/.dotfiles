import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt.labs.folderlistmodel
import Quickshell.Io
import qs.Services.Theme
import qs.Components.Icon

Rectangle {
    id: root

    property string type: "cpu"

    radius: 15
    color: Theme.surfaceContainer

    property int cpuTemp: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0
    property real cpuPerc: 0
    property real usedMemoryPerc: 0

    readonly property real value: {
        switch (type) {
        case "cpu":
            return cpuPerc;
        case "memory":
            return usedMemoryPerc;
        case "temp":
            return Math.min(cpuTemp / 100, 1.0);
        default:
            return 0;
        }
    }

    readonly property var config: {
        "cpu": {
            icon: "cpu",
            label: "CPU",
            color: Theme.primaryColor
        },
        "memory": {
            icon: "memory",
            label: "RAM",
            color: Theme.secondaryColor
        },
        "temp": {
            icon: "popcorn",
            label: "TEMP",
            color: Theme.tertiaryColor
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    FolderListModel {
        id: folderListModel
        folder: "file:///sys/class/hwmon"
    }

    FileView {
        id: hwmon
        property int index: 0
        property bool done: false
        property string fileName: "name"
        path: folderListModel.status === FolderListModel.Ready ? `file:///sys/class/hwmon/hwmon${Math.min(index, folderListModel.count - 1)}/${fileName}` : ""
        onLoaded: {
            if (!done) {
                if (text().includes("coretemp")) {
                    Qt.callLater(() => {
                        done = true;
                        fileName = "temp1_input";
                    });
                } else if (index < folderListModel.count - 1)
                    Qt.callLater(() => ++index);
            } else
                root.cpuTemp = Number(text()) / 1000;
        }
    }

    FileView {
        id: procStat
        path: "file:///proc/stat"
        onLoaded: {
            const cpuTimes = text().split(' ').slice(2, 9).map(Number);
            const idle = cpuTimes[3] + cpuTimes[4];
            const total = cpuTimes.reduce((acc, cur) => acc + cur, 0);
            const idleDiff = idle - root.lastCpuIdle;
            const totalDiff = total - root.lastCpuTotal;
            root.cpuPerc = root.lastCpuTotal > 0 && totalDiff > 0 ? 1 - idleDiff / totalDiff : 0;
            root.lastCpuIdle = idle;
            root.lastCpuTotal = total;
        }
    }

    FileView {
        id: procMemInfo
        path: "file:///proc/meminfo"
        onLoaded: {
            const memNumbers = text().split('\n').map(m => parseInt(m.split(':')[1]));
            root.usedMemoryPerc = 1 - memNumbers[2] / memNumbers[0];
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            hwmon.reload();
            procStat.reload();
            procMemInfo.reload();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignCenter

            Item {
                id: ringContainer
                anchors.centerIn: parent
                width: 110
                height: 110

                property real gapAngle: 70
                property real gapCenterAngle: 50

                Shape {
                    id: shape
                    anchors.fill: parent

                    ShapePath {
                        strokeWidth: 8
                        strokeColor: Theme.surfaceContainerHighest
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: shape.width / 2
                            centerY: shape.height / 2
                            radiusX: (shape.width - 8) / 2
                            radiusY: (shape.height - 8) / 2
                            startAngle: ringContainer.gapCenterAngle + ringContainer.gapAngle / 2
                            sweepAngle: 360 - ringContainer.gapAngle
                        }
                    }

                    ShapePath {
                        strokeWidth: 8
                        strokeColor: root.config[root.type].color
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: shape.width / 2
                            centerY: shape.height / 2
                            radiusX: (shape.width - 8) / 2
                            radiusY: (shape.height - 8) / 2
                            startAngle: ringContainer.gapCenterAngle + ringContainer.gapAngle / 2
                            sweepAngle: (360 - ringContainer.gapAngle) * root.value

                            Behavior on sweepAngle {
                                NumberAnimation {
                                    duration: 800
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }

                Icon {
                    id: gapIcon
                    name: root.config[root.type].icon
                    size: 26
                    color: root.config[root.type].color

                    property real radius: (ringContainer.width - 8) / 2

                    x: ringContainer.width / 2 + radius * Math.cos(ringContainer.gapCenterAngle * Math.PI / 180) - width / 2
                    y: ringContainer.height / 2 + radius * Math.sin(ringContainer.gapCenterAngle * Math.PI / 180) - height / 2
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: root.type === "temp" ? Math.round(root.cpuTemp) + "°C" : Math.round(root.value * 100) + "%"
                        color: Theme.onSurface
                        font.pixelSize: 20
                        font.family: "CaskaydiaCove NF"
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: root.config[root.type].label
                        color: Theme.onSurfaceVariant
                        font.pixelSize: 11
                        font.family: "CaskaydiaCove NF"
                        opacity: 0.7
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }
}
