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
        componentActive = false;
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
        path: folderListModel.status === FolderListModel.Ready ? `file:///sys/class/hwmon/hwmon${Math.min(index, folderListModel.count - 1)}/${fileName}` : ""

        onLoaded: {
            if (!componentActive)
                return;
            if (!done) {
                if (text().includes("coretemp")) {
                    Qt.callLater(() => {
                        if (componentActive) {
                            done = true;
                            fileName = "temp1_input";
                        }
                    });
                } else if (index < folderListModel.count - 1) {
                    Qt.callLater(() => {
                        if (componentActive)
                            ++index;
                    });
                }
            } else {
                cpuTemp = Number(text()) / 1000;
            }
        }
    }

    FileView {
        id: procStat
        path: "file:///proc/stat"
        onLoaded: {
            if (!componentActive)
                return;
            const cpuTimes = text().split(' ').slice(2, 9).map(Number);
            const idle = cpuTimes[3] + cpuTimes[4];
            const total = cpuTimes.reduce((acc, cur) => acc + cur, 0);
            const idleDiff = idle - lastCpuIdle;
            const totalDiff = total - lastCpuTotal;
            cpuPerc = lastCpuTotal > 0 && totalDiff > 0 ? 1 - idleDiff / totalDiff : 0;
            lastCpuIdle = idle;
            lastCpuTotal = total;
        }
    }

    FileView {
        id: procMemInfo
        path: "file:///proc/meminfo"
        onLoaded: {
            if (!componentActive)
                return;
            const memNumbers = text().split('\n').map(m => parseInt(m.split(':')[1]));
            usedMemoryPerc = 1 - memNumbers[2] / memNumbers[0];
        }
    }

    Timer {
        id: updateTimer
        interval: 1000
        running: componentActive
        repeat: true
        onTriggered: {
            if (componentActive) {
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
                Layout.fillWidth: true
                Layout.fillHeight: true

                property string itemType: "memory"
                property string itemIcon: "memory"
                property string itemLabel: "RAM"
                property real itemValue: usedMemoryPerc

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
                                    centerX: shape1.width / 2
                                    centerY: shape1.height / 2
                                    radiusX: (shape1.width - 10) / 2
                                    radiusY: (shape1.height - 10) / 2
                                    startAngle: ringContainer1.gapCenterAngle + ringContainer1.gapAngle / 2
                                    sweepAngle: (360 - ringContainer1.gapAngle) * usedMemoryPerc

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
                            name: "memory"
                            size: 24
                            color: Theme.secondaryColor

                            property real radius: (ringContainer1.width - 10) / 2

                            x: ringContainer1.width / 2 + radius * Math.cos(ringContainer1.gapCenterAngle * Math.PI / 180) - width / 2
                            y: ringContainer1.height / 2 + radius * Math.sin(ringContainer1.gapCenterAngle * Math.PI / 180) - height / 2
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: Math.round(usedMemoryPerc * 100) + "%"
                                color: Theme.onSurface
                                font.pixelSize: 20
                                font.family: "CaskaydiaCove NF"
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: "RAM"
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 12
                                font.family: "CaskaydiaCove NF"
                                opacity: 0.7
                                anchors.horizontalCenter: parent.horizontalCenter
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                property string itemType: "cpu"
                property string itemIcon: "cpu"
                property string itemLabel: "CPU"
                property real itemValue: cpuPerc

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
                                    centerX: shape2.width / 2
                                    centerY: shape2.height / 2
                                    radiusX: (shape2.width - 10) / 2
                                    radiusY: (shape2.height - 10) / 2
                                    startAngle: ringContainer2.gapCenterAngle + ringContainer2.gapAngle / 2
                                    sweepAngle: (360 - ringContainer2.gapAngle) * cpuPerc

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
                            name: "cpu"
                            size: 28
                            color: Theme.primaryColor

                            property real radius: (ringContainer2.width - 10) / 2

                            x: ringContainer2.width / 2 + radius * Math.cos(ringContainer2.gapCenterAngle * Math.PI / 180) - width / 2
                            y: ringContainer2.height / 2 + radius * Math.sin(ringContainer2.gapCenterAngle * Math.PI / 180) - height / 2
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: Math.round(cpuPerc * 100) + "%"
                                color: Theme.onSurface
                                font.pixelSize: 24
                                font.family: "CaskaydiaCove NF"
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: "CPU"
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 13
                                font.family: "CaskaydiaCove NF"
                                opacity: 0.7
                                anchors.horizontalCenter: parent.horizontalCenter
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                property string itemType: "temp"
                property string itemIcon: "popcorn"
                property string itemLabel: "TEMP"
                property real itemValue: Math.min(cpuTemp / 100, 1.0)

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
                                    centerX: shape3.width / 2
                                    centerY: shape3.height / 2
                                    radiusX: (shape3.width - 10) / 2
                                    radiusY: (shape3.height - 10) / 2
                                    startAngle: ringContainer3.gapCenterAngle + ringContainer3.gapAngle / 2
                                    sweepAngle: (360 - ringContainer3.gapAngle) * Math.min(cpuTemp / 100, 1.0)

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
                            name: "popcorn"
                            size: 24
                            color: Theme.tertiaryColor

                            property real radius: (ringContainer3.width - 10) / 2

                            x: ringContainer3.width / 2 + radius * Math.cos(ringContainer3.gapCenterAngle * Math.PI / 180) - width / 2
                            y: ringContainer3.height / 2 + radius * Math.sin(ringContainer3.gapCenterAngle * Math.PI / 180) - height / 2
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: Math.round(cpuTemp) + "°C"
                                color: Theme.onSurface
                                font.pixelSize: 20
                                font.family: "CaskaydiaCove NF"
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: "TEMP"
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 12
                                font.family: "CaskaydiaCove NF"
                                opacity: 0.7
                                anchors.horizontalCenter: parent.horizontalCenter
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }
        }
    }
}
