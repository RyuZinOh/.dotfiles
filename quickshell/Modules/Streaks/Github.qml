import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Services.Shapes

Item {
    id: root
    width: content.width
    height: 250
    property bool isHovered: false

    property var githubContributions: []
    property int totalContributions: 0
    property string username: "ryuzinoh"

    // monochrome color scheme
    readonly property color bg: "black"
    readonly property color textPrimary: "#e8e8e8"
    readonly property color textSecondary: "#6e6e6e"
    readonly property color layer1: "#1a1a1a"
    readonly property color layer2: "#2a2a2a"
    readonly property color accent: "#ffffff"

    function getContributionColor(level) {
        if (level === 0) {
            return root.layer1;
        }
        if (level === 1) {
            return root.layer2;
        }
        if (level === 2) {
            return "#4a4a4a";
        }
        if (level === 3) {
            return "#7a7a7a";
        }
        return root.accent;
    }

    //global layer
    Item {
        id: tooltipLayer
        anchors.fill: parent
        z: 9999

        Rectangle {
            id: tooltip
            visible: false
            radius: 6
            border.color: root.layer2
            border.width: 1
            color: root.layer1
            z: 10000
            opacity: 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }

            Text {
                id: tooltipText
                anchors.centerIn: parent
                color: root.textPrimary
                font.pixelSize: 11
                font.family: "CaskaydiaCove NF"
            }
        }

        function show(data, posX, posY) {
            tooltip.visible = true;
            tooltip.opacity = 1;
            tooltipText.text = `${data.count} contribution${data.count !== 1 ? "s" : ""} on ${data.date}`;

            tooltip.width = tooltipText.width + 16;
            tooltip.height = tooltipText.height + 12;
            tooltip.x = posX - tooltip.width - 12;  //left
            tooltip.y = posY - tooltip.height - 6;  // slight upward
        }
        function hide() {
            tooltip.opacity = 0;
            tooltip.visible = false;
        }
    }

    Timer {
        interval: 600000 //every ten mintues
        running: true
        repeat: true
        onTriggered: getContributions.running = true
    }

    Process {
        id: getContributions
        running: true
        command: ["curl", `https://github-contributions-api.jogruber.de/v4/${root.username}`]

        stdout: StdioCollector {
            onStreamFinished: {
                const json = JSON.parse(text);

                const oneYearAgo = new Date();
                oneYearAgo.setDate(oneYearAgo.getDate() - 365);

                root.totalContributions = json.contributions.filter(c => new Date(c.date) >= oneYearAgo).reduce((sum, c) => sum + c.count, 0);

                const today = new Date();
                const cutoff = new Date(today);
                cutoff.setDate(cutoff.getDate() - 280);

                root.githubContributions = json.contributions.filter(c => new Date(c.date) >= cutoff).sort((a, b) => new Date(a.date) - new Date(b.date));
            }
        }
    }

    PopoutShape {
        id: content
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.isHovered ? 650 : 2
        height: parent.height
        style: 1
        alignment: 2
        radius: 20
        color: root.bg

        Behavior on width {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 24
            opacity: root.isHovered ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 20

                // Header
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: `  ${root.username} - ${root.totalContributions.toLocaleString()} contributions in the last year`
                            color: root.textPrimary
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                            font.family: "CaskaydiaCove NF"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: ``
                            color: root.textSecondary
                            font.pixelSize: 12
                            font.family: "CaskaydiaCove NF"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // contributions grid
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    GridLayout {
                        anchors.centerIn: parent
                        rows: 7
                        columns: 40
                        rowSpacing: 4
                        columnSpacing: 4

                        Repeater {
                            model: 40
                            delegate: ColumnLayout {
                                spacing: 4
                                property int weekIndex: index

                                Repeater {
                                    model: 7
                                    delegate: Rectangle {
                                        width: 11
                                        height: 11
                                        radius: 2.5

                                        property int realIndex: weekIndex * 7 + index
                                        property var contribData: root.githubContributions[realIndex]

                                        color: root.getContributionColor(contribData?.level || 0)

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 200
                                                easing.type: Easing.OutQuad
                                            }
                                        }

                                        MouseArea {
                                            id: area

                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onExited: tooltipLayer.hide()

                                            onClicked: if (contribData) {
                                                tooltipLayer.show(contribData, mapToItem(root, width / 2, height / 2).x, mapToItem(root, width / 2, height / 2).y);
                                            }
                                        }

                                        scale: area.containsMouse ? 1.5 : 1.0
                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: 150
                                                easing.type: Easing.OutQuad
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Legends
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    Layout.topMargin: 26

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "Less"
                            color: root.textSecondary
                            font.pixelSize: 11
                            font.family: "CaskaydiaCove NF"
                        }

                        Repeater {
                            model: 5
                            Rectangle {
                                width: 11
                                height: 11
                                radius: 2.5
                                color: root.getContributionColor(index)
                            }
                        }

                        Text {
                            text: "More"
                            color: root.textSecondary
                            font.pixelSize: 11
                            font.family: "CaskaydiaCove NF"
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: root.isHovered = hovered
    }
}
