import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt.labs.folderlistmodel
import Quickshell.Io
import qs.Services.Theme

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
            icon: "󰻠",
            label: "CPU",
            color: Theme.primaryColor
        },
        "memory": {
            icon: "󰍛",
            label: "RAM",
            color: Theme.secondaryColor
        },
        "temp": {
            icon: "󰔏",
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

            Shape {
                id: shape
                anchors.centerIn: parent
                width: 70
                height: 70

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
                        startAngle: -90
                        sweepAngle: 360
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
                        startAngle: -90
                        sweepAngle: 360 * root.value

                        Behavior on sweepAngle {
                            NumberAnimation {
                                duration: 800
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Text {
                    text: root.type === "temp" ? Math.round(root.cpuTemp) + "°C" : Math.round(root.value * 100) + "%"
                    color: Theme.onSurface
                    font.pixelSize: 16
                    font.family: "CaskaydiaCove NF"
                    font.bold: true
                    anchors.centerIn: parent
                }
            }
        }

        Text {
            text: root.config[root.type].label
            color: Theme.onSurface
            font.pixelSize: 11
            font.family: "CaskaydiaCove NF"
            font.bold: true
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: root.config[root.type].icon
            color: root.config[root.type].color
            font.pixelSize: 20
            font.family: "CaskaydiaCove NF"
            Layout.alignment: Qt.AlignHCenter
            opacity: 0.6
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }
}
