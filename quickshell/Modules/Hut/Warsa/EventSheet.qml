pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Item {
    id: root

    property EventsDB eventsDb
    property int targetMonth: 0
    property int targetDay: 0
    property bool isEditing: false
    property string monthName: ""

    implicitHeight: sheetRect.height

    signal done
    signal closeRequested
    signal closing

    function openFor(month, day, cellX, cellY) {
        root.targetMonth = month;
        root.targetDay = day;
        const existing = root.eventsDb.get(month, day);
        if (existing) {
            titleInput.text = existing.title;
            descInput.text = existing.description;
            root.isEditing = true;
        } else {
            titleInput.text = "";
            descInput.text = "";
            root.isEditing = false;
        }
        sheetScale.origin.x = cellX - root.x;
        sheetScale.origin.y = cellY - root.y;
        root.visible = true;
        scaleIn.restart();
        root.forceActiveFocus();
    }

    function close() {
        scaleOut.restart();
    }

    visible: false
    opacity: 1
    transformOrigin: Item.Center

    transform: Scale {
        id: sheetScale
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: 1.0
        yScale: 1.0
    }

    SequentialAnimation {
        id: scaleIn
        ScriptAction {
            script: {
                root.visible = true;
                sheetRect.opacity = 1;
                sheetScale.xScale = 0.08;
                sheetScale.yScale = 0.08;
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: sheetScale
                property: "xScale"
                from: 0.08
                to: 1.0
                duration: 420
                easing.type: Easing.OutExpo
            }
            NumberAnimation {
                target: sheetScale
                property: "yScale"
                from: 0.08
                to: 1.0
                duration: 420
                easing.type: Easing.OutExpo
            }
        }
    }

    SequentialAnimation {
        id: scaleOut
        ScriptAction {
            script: root.closing()
        }
        ParallelAnimation {
            NumberAnimation {
                target: sheetScale
                property: "xScale"
                from: 1.0
                to: 0.08
                duration: 160
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: sheetScale
                property: "yScale"
                from: 1.0
                to: 0.08
                duration: 160
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: sheetRect
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 130
                easing.type: Easing.InQuad
            }
        }
        ScriptAction {
            script: {
                root.visible = false;
                sheetScale.xScale = 1.0;
                sheetScale.yScale = 1.0;
                sheetRect.opacity = 1.0;
                root.closeRequested();
            }
        }
    }

    Rectangle {
        id: sheetRect

        width: parent.width
        height: sheetCol.height + 28
        radius: 16
        color: Theme.surfaceContainer
        border.width: 1
        border.color: Theme.outlineVariant

        Column {
            id: sheetCol

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 14
                topMargin: 16
            }
            spacing: 10

            Item {
                width: parent.width
                height: 20

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.isEditing ? "Edit event" : "Add event"
                    font.pixelSize: 12
                    font.family: "CaskaydiaCove NF"
                    font.weight: Font.Medium
                    color: Theme.onSurface
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.monthName + " " + root.targetDay
                    font.pixelSize: 11
                    font.family: "CaskaydiaCove NF"
                    color: Theme.onSurfaceVariant
                }
            }

            Rectangle {
                width: parent.width
                height: 38
                radius: 10
                color: Theme.surfaceContainer
                border.width: titleInput.activeFocus ? 2 : 1
                border.color: titleInput.activeFocus ? Theme.primaryColor : Theme.outlineVariant
                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                TextInput {
                    id: titleInput
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.onSurface
                    font.pixelSize: 13
                    font.family: "CaskaydiaCove NF"
                    clip: true

                    Text {
                        visible: !titleInput.text && !titleInput.activeFocus
                        text: "Title"
                        color: Theme.onSurfaceVariant
                        font.pixelSize: 13
                        font.family: "CaskaydiaCove NF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Keys.onTabPressed: descInput.forceActiveFocus()
                    Keys.onReturnPressed: descInput.forceActiveFocus()
                }
            }

            Rectangle {
                width: parent.width
                height: 38
                radius: 10
                color: Theme.surfaceContainer
                border.width: descInput.activeFocus ? 2 : 1
                border.color: descInput.activeFocus ? Theme.primaryColor : Theme.outlineVariant
                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                TextInput {
                    id: descInput
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.onSurface
                    font.pixelSize: 13
                    font.family: "CaskaydiaCove NF"
                    clip: true

                    Text {
                        visible: !descInput.text && !descInput.activeFocus
                        text: "Description"
                        color: Theme.onSurfaceVariant
                        font.pixelSize: 13
                        font.family: "CaskaydiaCove NF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Keys.onReturnPressed: {
                        const t = titleInput.text.trim();
                        if (t.length === 0)
                            return;
                        root.eventsDb.save(root.targetMonth, root.targetDay, t, descInput.text.trim());
                        root.done();
                        root.close();
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 8
                layoutDirection: Qt.RightToLeft
                bottomPadding: 2

                Rectangle {
                    width: 70
                    height: 34
                    radius: 17
                    color: saveMouse.containsMouse ? Theme.primaryColor : Theme.primaryContainer
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Save"
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        font.weight: Font.Medium
                        color: Theme.onPrimaryContainer
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const t = titleInput.text.trim();
                            if (t.length === 0)
                                return;
                            root.eventsDb.save(root.targetMonth, root.targetDay, t, descInput.text.trim());
                            root.done();
                            root.close();
                        }
                    }
                }

                Rectangle {
                    width: 70
                    height: 34
                    radius: 17
                    color: cancelMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerLow
                    border.width: 1
                    border.color: Theme.outlineVariant
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        color: Theme.onSurface
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }

                Rectangle {
                    visible: root.isEditing
                    width: 70
                    height: 34
                    radius: 17
                    color: deleteMouse.containsMouse ? Theme.errorContainer : Theme.surfaceContainerLow
                    border.width: 1
                    border.color: Theme.outlineVariant
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Delete"
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        color: deleteMouse.containsMouse ? Theme.onErrorContainer : Theme.onSurface
                    }

                    MouseArea {
                        id: deleteMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.eventsDb.remove(root.targetMonth, root.targetDay);
                            root.done();
                            root.close();
                        }
                    }
                }
            }
        }
    }
}
