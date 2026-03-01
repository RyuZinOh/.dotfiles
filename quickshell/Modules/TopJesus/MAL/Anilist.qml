pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.LocalStorage
import qs.Services.Theme

Item {
    id: root
    width: 375
    height: 350

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
            const animeRows = tx.executeSql("SELECT name FROM anime");
            for (let i = 0; i < animeRows.rows.length; i++)
                animeModel.append({
                    name: animeRows.rows.item(i).name
                });

            const todoRows = tx.executeSql("SELECT name FROM todo");
            for (let i = 0; i < todoRows.rows.length; i++)
                todoModel.append({
                    name: todoRows.rows.item(i).name
                });
        });
    }

    function saveData() {
        db.transaction(tx => {
            tx.executeSql("DELETE FROM anime");
            tx.executeSql("DELETE FROM todo");

            for (let i = 0; i < animeModel.count; i++) {
                tx.executeSql("INSERT INTO anime VALUES (?)", [animeModel.get(i).name]);
            }

            for (let j = 0; j < todoModel.count; j++) {
                tx.executeSql("INSERT INTO todo VALUES (?)", [todoModel.get(j).name]);
            }
        });
    }

    Component.onCompleted: {
        initDb();
        loadData();
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.backgroundColor
        border.width: 1
        border.color: Theme.outlineVariant
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 1
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: Theme.surfaceContainerLow
                radius: 12

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: parent.radius
                    color: parent.color
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4

                    Repeater {
                        model: ["Anime", "Tasks"]
                        delegate: Rectangle {
                            id: tabBtn
                            required property string modelData
                            required property int index
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: root.currentTab === index ? Theme.primaryContainer : "transparent"
                            radius: 8
                            border.width: root.currentTab === index ? 1 : 0
                            border.color: Theme.outlineVariant

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                            Behavior on border.width {
                                NumberAnimation {
                                    duration: 200
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: tabBtn.modelData
                                color: root.currentTab === tabBtn.index ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                                font {
                                    pixelSize: 14
                                    family: "CaskaydiaCove NF"
                                    weight: root.currentTab === tabBtn.index ? Font.Medium : Font.Normal
                                }
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

            Rectangle {
                Layout.fillWidth: true
                color: Theme.outlineVariant
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Item {
                    width: parent.width * 2
                    height: parent.height
                    x: -root.currentTab * parent.width

                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }

                    Repeater {
                        model: [
                            {
                                listModel: animeModel,
                                placeholder: "Add anime..."
                            },
                            {
                                listModel: todoModel,
                                placeholder: "Add task..."
                            }
                        ]

                        delegate: ListTab {
                            required property var modelData
                            required property int index

                            x: index * (parent.width / 2)
                            width: parent.width / 2
                            height: parent.height

                            listModel: modelData.listModel
                            placeholder: modelData.placeholder
                            onSaveRequested: root.saveData()
                            onReloadRequested: root.loadData()
                        }
                    }
                }
            }
        }
    }
}
