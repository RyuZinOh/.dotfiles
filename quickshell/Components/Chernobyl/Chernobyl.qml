pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import qs.Services.Theme
import qs.Configuration.Chernobyl
import Quickshell

Item {
    id: root

    readonly property int panelSize: 500
    readonly property int panelMinHeight: 80
    readonly property int cellSize: 100
    readonly property int cols: 4
    readonly property int radius: 12
    readonly property string font: "CaskaydiaCove NF"

    function contentHeight() {
        const cnt = filteredApps().length;
        if (cnt === 0)
            return panelMinHeight;
        const rows = Math.ceil(cnt / root.cols);
        return Math.min(Math.max(62 + rows * root.cellSize, panelMinHeight), panelSize);
    }

    function filteredApps() {
        const q = searchInput.text.trim().toLowerCase();
        const apps = [...DesktopEntries.applications.values];
        return apps.filter(d => d.name && (!q || d.name.toLowerCase().includes(q))).sort((a, b) => a.name.localeCompare(b.name));
    }

    anchors.fill: parent
    focus: true
    Component.onCompleted: {
        ChernobylConfig.panelHeight = contentHeight();
        searchInput.forceActiveFocus();
        openAnim.start();
    }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            ChernobylConfig.dismiss();
            event.accepted = true;
        }
    }

    ScriptModel {
        id: filtered
        values: root.filteredApps()
    }

    Rectangle {
        id: panel

        property real scaleY: 1

        anchors.centerIn: parent
        onHeightChanged: ChernobylConfig.panelHeight = height
        width: root.cols * root.cellSize + 24
        height: root.contentHeight()
        radius: root.radius
        color: Theme.surfaceContainerLow
        clip: true

        SequentialAnimation {
            id: openAnim

            NumberAnimation {
                target: panel
                property: "scaleY"
                from: 0.5
                to: 1
                duration: 680
                easing.type: Easing.OutExpo
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => {
                root.forceActiveFocus();
                mouse.accepted = true;
            }
        }

        Row {
            id: topRow

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 12
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Rectangle {
                width: parent.width
                height: 38
                radius: root.radius
                color: Theme.surfaceContainer
                border.color: searchInput.activeFocus ? Theme.outlineVariant : "transparent"
                border.width: 1
                clip: true

                Text {
                    id: searchIcon

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: "\uedfb"
                    font.family: root.font
                    font.pixelSize: 15
                    color: Theme.onSurfaceVariant
                }

                TextField {
                    id: searchInput

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: searchIcon.right
                    anchors.right: parent.right
                    anchors.leftMargin: 6
                    anchors.rightMargin: 8
                    height: 38
                    placeholderText: "Search apps…"
                    placeholderTextColor: Theme.onSurfaceVariant
                    color: Theme.onSurface
                    font.family: root.font
                    font.pixelSize: 13
                    focus: true
                    onTextChanged: {
                        filtered.values = root.filteredApps();
                        gridView.forceLayout();
                    }
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            ChernobylConfig.dismiss();
                            event.accepted = true;
                        }
                    }

                    background: Item {}
                }
            }
        }

        Item {
            anchors.top: topRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 12
            anchors.topMargin: 8

            Text {
                anchors.centerIn: parent
                visible: gridView.count === 0
                text: "No applications found"
                color: Theme.onSurfaceVariant
                font.family: root.font
                font.pixelSize: 13
            }

            GridView {
                id: gridView

                anchors.fill: parent
                clip: true
                cellWidth: root.cellSize
                cellHeight: root.cellSize

                model: filtered

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                delegate: Item {
                    id: delegateRoot

                    required property var modelData

                    width: gridView.cellWidth
                    height: gridView.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: root.radius - 4
                        color: itemMouse.containsMouse ? Theme.primaryContainer : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                                easing.type: Easing.OutQuad
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 36
                                height: 36
                                source: Quickshell.iconPath(delegateRoot.modelData.icon, "application-x-executable")
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: root.cellSize - 16
                                text: delegateRoot.modelData.name
                                color: Theme.onSurface
                                font.family: root.font
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: itemMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                const entry = delegateRoot.modelData;
                                const cmd = entry.command;

                                if (entry.runInTerminal) {
                                    Quickshell.execDetached(["kitty", "-e", ...cmd]);
                                } else {
                                    Quickshell.execDetached(cmd);
                                }
                                ChernobylConfig.dismiss();
                            }
                        }
                    }
                }
            }
        }

        transform: Scale {
            origin.x: panel.width / 2
            origin.y: panel.height / 2
            yScale: panel.scaleY
        }

        Behavior on height {
            NumberAnimation {
                duration: 1100
                easing.type: Easing.OutElastic
                easing.amplitude: 1
                easing.period: 0.55
            }
        }
    }

    Connections {
        function onShowChernobyl() {
        }
        function onHideChernobyl() {
        }
        target: ChernobylConfig
    }
}
