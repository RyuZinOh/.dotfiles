pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Services.Theme

Item {
    id: tabRoot
    required property var listModel
    required property string placeholder

    signal saveRequested
    signal reloadRequested

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 0

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: tabRoot.listModel
            spacing: 8

            delegate: Rectangle {
                id: del
                required property string name
                required property int index

                width: ListView.view.width
                height: 48
                color: Theme.surfaceContainer
                radius: 12
                border.width: 1
                border.color: Theme.outlineVariant

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 16
                        rightMargin: 12
                    }
                    spacing: 12

                    Text {
                        text: del.name
                        color: Theme.onSurface
                        font {
                            pixelSize: 14
                            family: "CaskaydiaCove NF"
                        }
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter
                        radius: delHover.hovered ? 16 : 6
                        color: Theme.primaryColor
                        border.width: 1
                        border.color: Theme.outlineVariant

                        Behavior on radius {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: Theme.onPrimary
                            font {
                                pixelSize: 16
                                family: "CaskaydiaCove NF"
                            }
                        }

                        HoverHandler {
                            id: delHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                tabRoot.listModel.remove(del.index);
                                tabRoot.saveRequested();
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Layout.topMargin: 8

            RowLayout {
                anchors.fill: parent
                spacing: 8
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    radius: 20
                    color: refreshHover.hovered ? Theme.surfaceContainerHigh : Theme.surfaceContainer
                    border.width: 1
                    border.color: Theme.outlineVariant

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        color: Theme.primaryColor
                        font {
                            pixelSize: 18
                            family: "CaskaydiaCove NF"
                        }

                        RotationAnimator on rotation {
                            id: spin
                            from: 0
                            to: 360
                            duration: 600
                            loops: 1
                        }
                    }

                    HoverHandler {
                        id: refreshHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            spin.start();
                            tabRoot.reloadRequested();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: Theme.surfaceContainerHigh
                    radius: 24
                    border.width: input.activeFocus ? 2 : 1
                    border.color: input.activeFocus ? Theme.primaryColor : Theme.outlineVariant

                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    TextInput {
                        id: input
                        anchors {
                            fill: parent
                            leftMargin: 20
                            rightMargin: 20
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.onSurface
                        font {
                            pixelSize: 14
                            family: "CaskaydiaCove NF"
                        }
                        clip: true

                        Text {
                            visible: !input.text && !input.activeFocus
                            text: tabRoot.placeholder
                            color: Theme.onSurfaceVariant
                            font {
                                pixelSize: 14
                                family: "CaskaydiaCove NF"
                            }
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Keys.onReturnPressed: {
                            const t = input.text.trim();
                            if (t.length > 0) {
                                tabRoot.listModel.append({
                                    name: t
                                });
                                input.text = "";
                                tabRoot.saveRequested();
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        onClicked: input.forceActiveFocus()
                    }
                }
            }
        }
    }
}
