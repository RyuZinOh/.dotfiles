pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.LocalStorage
import qs.Services.Theme

Item {
    id: root

    property int currentTab: 0

    ListModel {
        id: animeModel
    }
    ListModel {
        id: todoModel
    }

    property var db: LocalStorage.openDatabaseSync("malDB", "1.0", "MAL Database", 1000000)

    function initDb() {
        db.transaction(tx => {
            tx.executeSql("CREATE TABLE IF NOT EXISTS anime (name TEXT NOT NULL)");
            tx.executeSql("CREATE TABLE IF NOT EXISTS todo  (name TEXT NOT NULL)");
        });
    }

    function loadData() {
        animeModel.clear();
        todoModel.clear();
        db.readTransaction(tx => {
            const a = tx.executeSql("SELECT name FROM anime");
            for (let i = 0; i < a.rows.length; i++)
                animeModel.append({
                    name: a.rows.item(i).name
                });
            const t = tx.executeSql("SELECT name FROM todo");
            for (let i = 0; i < t.rows.length; i++)
                todoModel.append({
                    name: t.rows.item(i).name
                });
        });
    }

    function saveData() {
        db.transaction(tx => {
            tx.executeSql("DELETE FROM anime");
            tx.executeSql("DELETE FROM todo");
            for (let i = 0; i < animeModel.count; i++)
                tx.executeSql("INSERT INTO anime VALUES (?)", [animeModel.get(i).name]);
            for (let j = 0; j < todoModel.count; j++)
                tx.executeSql("INSERT INTO todo VALUES (?)", [todoModel.get(j).name]);
        });
    }

    Component.onCompleted: {
        initDb();
        loadData();
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        color: "transparent"
        radius: 12
        border.width: 1
        border.color: Theme.outlineVariant
        clip: true

        Rectangle {
            id: tabBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 8
            }
            height: 28
            radius: 6
            color: Theme.surfaceContainerLow
            border.width: 1
            border.color: Theme.outlineVariant

            Row {
                anchors.fill: parent
                anchors.margins: 3
                spacing: 3

                Repeater {
                    model: ["Anime", "Tasks"]
                    delegate: Rectangle {
                        id: tabBtn
                        required property string modelData
                        required property int index
                        width: (parent.width - 9) / 2
                        height: parent.height
                        color: root.currentTab === index ? Theme.primaryContainer : "transparent"
                        radius: 4
                        border.width: root.currentTab === index ? 1 : 0
                        border.color: Theme.outlineVariant
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: tabBtn.modelData
                            color: root.currentTab === tabBtn.index ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                            font.pixelSize: 12
                            font.family: "CaskaydiaCove NF"
                            font.weight: root.currentTab === tabBtn.index ? Font.Medium : Font.Normal
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = tabBtn.index
                        }
                    }
                }
            }
        }

        Row {
            id: inputRow
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 8
            }
            height: 32
            spacing: 6

            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: rHover.hovered ? Theme.surfaceContainerHigh : Theme.surfaceContainerLow
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
                    font.pixelSize: 14
                    font.family: "CaskaydiaCove NF"
                    RotationAnimator on rotation {
                        id: spin
                        from: 0
                        to: 360
                        duration: 600
                        loops: 1
                    }
                }
                HoverHandler {
                    id: rHover
                    cursorShape: Qt.PointingHandCursor
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        spin.start();
                        root.loadData();
                    }
                }
            }

            Rectangle {
                width: parent.width - 38
                height: 32
                color: Theme.surfaceContainerHigh
                radius: 16
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
                        leftMargin: 12
                        rightMargin: 12
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.onSurface
                    font.pixelSize: 12
                    font.family: "CaskaydiaCove NF"
                    clip: true

                    Text {
                        visible: !input.text && !input.activeFocus
                        text: root.currentTab === 0 ? "Add anime..." : "Add task..."
                        color: Theme.onSurfaceVariant
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Keys.onReturnPressed: {
                        const t = input.text.trim();
                        if (t.length > 0) {
                            (root.currentTab === 0 ? animeModel : todoModel).append({
                                name: t
                            });
                            input.text = "";
                            root.saveData();
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

        ListView {
            anchors {
                top: tabBar.bottom
                topMargin: 6
                bottom: inputRow.top
                bottomMargin: 6
                left: parent.left
                leftMargin: 8
                right: parent.right
                rightMargin: 8
            }
            clip: true
            model: root.currentTab === 0 ? animeModel : todoModel
            spacing: 5

            delegate: Rectangle {
                id: del
                required property string name
                required property int index
                width: ListView.view.width
                height: 32
                color: Theme.surfaceContainerLow
                radius: 8
                border.width: 1
                border.color: Theme.outlineVariant

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 8
                    }
                    spacing: 8

                    Text {
                        text: del.name
                        color: Theme.onSurface
                        font.pixelSize: 12
                        font.family: "CaskaydiaCove NF"
                        width: parent.width - 36
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        radius: dHover.hovered ? 12 : 5
                        color: Theme.primaryColor
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
                            font.pixelSize: 12
                            font.family: "CaskaydiaCove NF"
                        }
                        HoverHandler {
                            id: dHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                (root.currentTab === 0 ? animeModel : todoModel).remove(del.index);
                                root.saveData();
                            }
                        }
                    }
                }
            }
        }
    }
}
