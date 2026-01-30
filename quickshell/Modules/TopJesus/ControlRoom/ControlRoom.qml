import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt.labs.folderlistmodel
import Quickshell.Io
import qs.Services.Theme
import qs.Components.Icon

Item {
    id: root

    property int cpuTemp: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0
    property real cpuPerc: 0
    property real usedMemoryPerc: 0
    property bool componentActive: true

    Component.onDestruction: {
        root.componentActive = false;
        updateTimer.running = false;
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
        path: folderListModel.status === FolderListModel.Ready ? `file:///sys/class/hwmon/hwmon${Math.min(hwmon.index, folderListModel.count - 1)}/${hwmon.fileName}` : ""

        onLoaded: {
            if (!root.componentActive)
                return;
            if (!hwmon.done) {
                if (hwmon.text().includes("coretemp")) {
                    Qt.callLater(() => {
                        if (root.componentActive) {
                            hwmon.done = true;
                            hwmon.fileName = "temp1_input";
                        }
                    });
                } else if (hwmon.index < folderListModel.count - 1) {
                    Qt.callLater(() => {
                        if (root.componentActive)
                            ++hwmon.index;
                    });
                }
            } else {
                root.cpuTemp = Number(hwmon.text()) / 1000;
            }
        }
    }

    FileView {
        id: procStat
        path: "file:///proc/stat"
        onLoaded: {
            if (!root.componentActive)
                return;
            const cpuTimes = procStat.text().split(' ').slice(2, 9).map(Number);
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
            if (!root.componentActive)
                return;
            const memNumbers = procMemInfo.text().split('\n').map(m => parseInt(m.split(':')[1]));
            root.usedMemoryPerc = 1 - memNumbers[2] / memNumbers[0];
        }
    }

    Timer {
        id: updateTimer
        interval: 1000
        running: root.componentActive
        repeat: true
        onTriggered: {
            if (root.componentActive) {
                hwmon.reload();
                procStat.reload();
                procMemInfo.reload();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceContainer
        radius: 16
        border.width: 1
        border.color: Theme.outlineVariant

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Item {
                id: memoryItem
                Layout.fillWidth: true
                Layout.fillHeight: true

                property string itemType: "memory"
                property string itemIcon: "memory"
                property string itemLabel: "RAM"
                property real itemValue: root.usedMemoryPerc

                Rectangle {
                    anchors.fill: parent
                    color: Theme.surfaceContainerLow
                    radius: 12
                    border.width: 1
                    border.color: Theme.outlineVariant

                    Item {
                        id: ringContainer1
                        anchors.centerIn: parent
                        width: 120
                        height: 120

                        readonly property real gapAngle: 70
                        readonly property real gapCenterAngle: 50

                        Shape {
                            id: shape1
                            anchors.fill: parent

                            layer.enabled: true
                            layer.smooth: true
                            layer.samples: 4
                            antialiasing: true

                            ShapePath {
                                strokeWidth: 10
                                strokeColor: Theme.surfaceContainerHighest
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap

                                PathAngleArc {
                                    centerX: shape1.width / 2
                                    centerY: shape1.height / 2
                                    radiusX: (shape1.width - 10) / 2
                                    radiusY: (shape1.height - 10) / 2
                                    startAngle: ringContainer1.gapCenterAngle + ringContainer1.gapAngle / 2
                                    sweepAngle: 360 - ringContainer1.gapAngle
                                }
                            }

                            ShapePath {
                                strokeWidth: 10
                                strokeColor: Theme.secondaryColor
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap

                                PathAngleArc {
                                    id: memoryArc
                                    centerX: shape1.width / 2
                                    centerY: shape1.height / 2
                                    radiusX: (shape1.width - 10) / 2
                                    radiusY: (shape1.height - 10) / 2
                                    startAngle: ringContainer1.gapCenterAngle + ringContainer1.gapAngle / 2
                                    sweepAngle: (360 - ringContainer1.gapAngle) * root.usedMemoryPerc

                                    Behavior on sweepAngle {
                                        NumberAnimation {
                                            duration: 600
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                        }

                        Icon {
                            id: memoryIcon
                            name: "memory"
                            size: 24
                            color: Theme.secondaryColor

                            property real radius: (ringContainer1.width - 10) / 2

                            x: ringContainer1.width / 2 + memoryIcon.radius * Math.cos(ringContainer1.gapCenterAngle * Math.PI / 180) - memoryIcon.width / 2
                            y: ringContainer1.height / 2 + memoryIcon.radius * Math.sin(ringContainer1.gapCenterAngle * Math.PI / 180) - memoryIcon.height / 2
                        }

                        Column {
                            id: memoryColumn
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: Math.round(root.usedMemoryPerc * 100) + "%"
                                color: Theme.onSurface
                                font.pixelSize: 20
                                font.family: "CaskaydiaCove NF"
                                font.bold: true
                                anchors.horizontalCenter: memoryColumn.horizontalCenter
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: "RAM"
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 12
                                font.family: "CaskaydiaCove NF"
                                opacity: 0.7
                                anchors.horizontalCenter: memoryColumn.horizontalCenter
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }

            Item {
                id: cpuItem
                Layout.fillWidth: true
                Layout.fillHeight: true

                property string itemType: "cpu"
                property string itemIcon: "cpu"
                property string itemLabel: "CPU"
                property real itemValue: root.cpuPerc

                Rectangle {
                    anchors.fill: parent
                    color: Theme.surfaceContainerLow
                    radius: 12
                    border.width: 1
                    border.color: Theme.outlineVariant

                    Item {
                        id: ringContainer2
                        anchors.centerIn: parent
                        width: 140
                        height: 140

                        readonly property real gapAngle: 70
                        readonly property real gapCenterAngle: 50

                        Shape {
                            id: shape2
                            anchors.fill: parent

                            layer.enabled: true
                            layer.smooth: true
                            layer.samples: 4
                            antialiasing: true

                            ShapePath {
                                strokeWidth: 10
                                strokeColor: Theme.surfaceContainerHighest
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap

                                PathAngleArc {
                                    centerX: shape2.width / 2
                                    centerY: shape2.height / 2
                                    radiusX: (shape2.width - 10) / 2
                                    radiusY: (shape2.height - 10) / 2
                                    startAngle: ringContainer2.gapCenterAngle + ringContainer2.gapAngle / 2
                                    sweepAngle: 360 - ringContainer2.gapAngle
                                }
                            }

                            ShapePath {
                                strokeWidth: 10
                                strokeColor: Theme.primaryColor
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap

                                PathAngleArc {
                                    id: cpuArc
                                    centerX: shape2.width / 2
                                    centerY: shape2.height / 2
                                    radiusX: (shape2.width - 10) / 2
                                    radiusY: (shape2.height - 10) / 2
                                    startAngle: ringContainer2.gapCenterAngle + ringContainer2.gapAngle / 2
                                    sweepAngle: (360 - ringContainer2.gapAngle) * root.cpuPerc

                                    Behavior on sweepAngle {
                                        NumberAnimation {
                                            duration: 600
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                        }

                        Icon {
                            id: cpuIcon
                            name: "cpu"
                            size: 28
                            color: Theme.primaryColor

                            property real radius: (ringContainer2.width - 10) / 2

                            x: ringContainer2.width / 2 + cpuIcon.radius * Math.cos(ringContainer2.gapCenterAngle * Math.PI / 180) - cpuIcon.width / 2
                            y: ringContainer2.height / 2 + cpuIcon.radius * Math.sin(ringContainer2.gapCenterAngle * Math.PI / 180) - cpuIcon.height / 2
                        }

                        Column {
                            id: cpuColumn
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: Math.round(root.cpuPerc * 100) + "%"
                                color: Theme.onSurface
                                font.pixelSize: 24
                                font.family: "CaskaydiaCove NF"
                                font.bold: true
                                anchors.horizontalCenter: cpuColumn.horizontalCenter
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: "CPU"
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 13
                                font.family: "CaskaydiaCove NF"
                                opacity: 0.7
                                anchors.horizontalCenter: cpuColumn.horizontalCenter
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }

            Item {
                id: tempItem
                Layout.fillWidth: true
                Layout.fillHeight: true

                property string itemType: "temp"
                property string itemIcon: "popcorn"
                property string itemLabel: "TEMP"
                property real itemValue: Math.min(root.cpuTemp / 100, 1.0)

                Rectangle {
                    anchors.fill: parent
                    color: Theme.surfaceContainerLow
                    radius: 12
                    border.width: 1
                    border.color: Theme.outlineVariant

                    Item {
                        id: ringContainer3
                        anchors.centerIn: parent
                        width: 120
                        height: 120

                        readonly property real gapAngle: 70
                        readonly property real gapCenterAngle: 50

                        Shape {
                            id: shape3
                            anchors.fill: parent

                            layer.enabled: true
                            layer.smooth: true
                            layer.samples: 4
                            antialiasing: true

                            ShapePath {
                                strokeWidth: 10
                                strokeColor: Theme.surfaceContainerHighest
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap

                                PathAngleArc {
                                    centerX: shape3.width / 2
                                    centerY: shape3.height / 2
                                    radiusX: (shape3.width - 10) / 2
                                    radiusY: (shape3.height - 10) / 2
                                    startAngle: ringContainer3.gapCenterAngle + ringContainer3.gapAngle / 2
                                    sweepAngle: 360 - ringContainer3.gapAngle
                                }
                            }

                            ShapePath {
                                strokeWidth: 10
                                strokeColor: Theme.tertiaryColor
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap

                                PathAngleArc {
                                    id: tempArc
                                    centerX: shape3.width / 2
                                    centerY: shape3.height / 2
                                    radiusX: (shape3.width - 10) / 2
                                    radiusY: (shape3.height - 10) / 2
                                    startAngle: ringContainer3.gapCenterAngle + ringContainer3.gapAngle / 2
                                    sweepAngle: (360 - ringContainer3.gapAngle) * Math.min(root.cpuTemp / 100, 1.0)

                                    Behavior on sweepAngle {
                                        NumberAnimation {
                                            duration: 600
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                        }

                        Icon {
                            id: tempIcon
                            name: "popcorn"
                            size: 24
                            color: Theme.tertiaryColor

                            property real radius: (ringContainer3.width - 10) / 2

                            x: ringContainer3.width / 2 + tempIcon.radius * Math.cos(ringContainer3.gapCenterAngle * Math.PI / 180) - tempIcon.width / 2
                            y: ringContainer3.height / 2 + tempIcon.radius * Math.sin(ringContainer3.gapCenterAngle * Math.PI / 180) - tempIcon.height / 2
                        }

                        Column {
                            id: tempColumn
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: Math.round(root.cpuTemp) + "°C"
                                color: Theme.onSurface
                                font.pixelSize: 20
                                font.family: "CaskaydiaCove NF"
                                font.bold: true
                                anchors.horizontalCenter: tempColumn.horizontalCenter
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: "TEMP"
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 12
                                font.family: "CaskaydiaCove NF"
                                opacity: 0.7
                                anchors.horizontalCenter: tempColumn.horizontalCenter
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }
        }
    }
}
