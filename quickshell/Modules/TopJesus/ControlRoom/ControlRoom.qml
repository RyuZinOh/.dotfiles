pragma ComponentBehavior: Bound
import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Io
import qs.Services.Theme

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
            if (!root.componentActive) return;
            if (!hwmon.done) {
                if (hwmon.text().includes("coretemp"))
                    Qt.callLater(() => { if (!root.componentActive) return; hwmon.done = true; hwmon.fileName = "temp1_input"; });
                else if (hwmon.index < folderListModel.count - 1)
                    Qt.callLater(() => { if (root.componentActive) ++hwmon.index; });
            } else {
                root.cpuTemp = Number(hwmon.text()) / 1000;
            }
        }
    }

    FileView {
        id: procStat
        path: "file:///proc/stat"
        onLoaded: {
            if (!root.componentActive) return;
            const t = procStat.text().split(' ').slice(2, 9).map(Number);
            const idle = t[3] + t[4];
            const total = t.reduce((a, c) => a + c, 0);
            const di = idle - root.lastCpuIdle;
            const dt = total - root.lastCpuTotal;
            root.cpuPerc = root.lastCpuTotal > 0 && dt > 0 ? 1 - di / dt : 0;
            root.lastCpuIdle = idle;
            root.lastCpuTotal = total;
        }
    }

    FileView {
        id: procMemInfo
        path: "file:///proc/meminfo"
        onLoaded: {
            if (!root.componentActive) return;
            const n = procMemInfo.text().split('\n').map(m => parseInt(m.split(':')[1]));
            root.usedMemoryPerc = 1 - n[2] / n[0];
        }
    }

    Timer {
        id: updateTimer
        interval: 1000
        running: root.componentActive
        repeat: true
        onTriggered: {
            if (!root.componentActive) return;
            hwmon.reload();
            procStat.reload();
            procMemInfo.reload();
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Repeater {
            model: [{
                "label": "RAM",
                "icon": "\udb80\udf5b",
                "idx": 0
            }, {
                "label": "CPU",
                "icon": "\udb83\udee0",
                "idx": 1
            }, {
                "label": "TEMP",
                "icon": "\udb82\udd8c",
                "idx": 2
            }]

            delegate: Item {
                id: card

                required property var modelData
                readonly property real val: modelData.idx === 0 ? root.usedMemoryPerc : modelData.idx === 1 ? root.cpuPerc : Math.min(root.cpuTemp / 100, 1)
                readonly property color accent: modelData.idx === 0 ? Theme.secondaryColor : modelData.idx === 1 ? Theme.primaryColor : Theme.tertiaryColor
                readonly property string valueText: modelData.idx === 2 ? Math.round(root.cpuTemp) + "°" : Math.round(val * 100) + "%"
                property real animatedVal: 0

                Behavior on animatedVal {
                    NumberAnimation { duration: 700; easing.type: Easing.OutCubic }
                }

                onValChanged: card.animatedVal = card.val

                Layout.fillWidth: true
                Layout.fillHeight: true

                Item {
                    id: ring

                    readonly property real gapAngle: 80
                    readonly property real gapStart: 50
                    readonly property real arcR: (width - 8) / 2
                    readonly property real fullSweep: 360 - gapAngle
                    readonly property real arcStartDeg: gapStart + gapAngle / 2
                    readonly property real iconRad: gapStart * Math.PI / 180

                    function sineArcPath(cx, cy, r, startDeg, sweepDeg, amp, freq) {
                        const steps = Math.max(2, Math.round(Math.abs(sweepDeg) * 2));
                        const startRad = startDeg * Math.PI / 180;
                        const sweepRad = sweepDeg * Math.PI / 180;
                        let d = "";
                        for (let i = 0; i <= steps; i++) {
                            const t = i / steps;
                            const angle = startRad + sweepRad * t;
                            const wave = amp * Math.sin(t * freq * Math.PI);
                            const rr = r + wave;
                            const x = cx + rr * Math.cos(angle);
                            const y = cy + rr * Math.sin(angle);
                            d += (i === 0 ? `M ${x} ${y}` : ` L ${x} ${y}`);
                        }
                        return d;
                    }

                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) * 0.8
                    height: width

                    Shape {
                        anchors.fill: parent
                        layer.enabled: true
                        layer.smooth: true
                        layer.samples: 8
                        antialiasing: true

                        ShapePath {
                            strokeWidth: 3
                            strokeColor: card.accent
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap

                            PathSvg {
                                path: ring.sineArcPath(
                                    ring.width / 2,
                                    ring.height / 2,
                                    ring.arcR,
                                    ring.arcStartDeg,
                                    ring.fullSweep * card.animatedVal,
                                    2.5,
                                    5
                                )
                            }
                        }
                    }

                    Text {
                        text: card.modelData.icon
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: Math.max(16, ring.width * 0.26)
                        color: card.accent
                        x: ring.width / 2 + ring.arcR * Math.cos(ring.iconRad) - width / 2
                        y: ring.height / 2 + ring.arcR * Math.sin(ring.iconRad) - height / 2

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: card.valueText
                            color: Theme.onSurface
                            font.pixelSize: Math.max(12, ring.width * 0.17)
                            font.family: "CaskaydiaCove NF"
                            font.bold: true
                            renderType: Text.NativeRendering
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: card.modelData.label
                            color: Theme.onSurfaceVariant
                            font.pixelSize: Math.max(9, ring.width * 0.1)
                            font.family: "CaskaydiaCove NF"
                            opacity: 0.65
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }
        }
    }
}
