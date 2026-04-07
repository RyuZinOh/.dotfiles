pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.LocalStorage
import qs.Services.Theme

Item {
    id: root

    property string currentTab: "Hiragana"
    readonly property var tabs: ["Hiragana", "Katakana", "Kanji"]
    property var db: LocalStorage.openDatabaseSync("malDB", "1.0", "MAL Database", 1e+06)

    function loadTab(tab) {
        charModel.clear();
        db.readTransaction((tx) => {
            const r = tx.executeSql("SELECT character, meaning FROM nihongo WHERE category = ?", [tab]);
            for (let i = 0; i < r.rows.length; i++) charModel.append({
                "kanji": r.rows.item(i).character,
                "meaning": r.rows.item(i).meaning
            })
        });
    }

    Component.onCompleted: loadTab(root.currentTab)
    onCurrentTabChanged: loadTab(root.currentTab)

    ListModel {
        id: charModel
    }

    Rectangle {
        id: tabBar

        height: 42
        radius: 10
        color: Theme.surfaceContainerLow
        border.width: 1
        border.color: Theme.outlineVariant

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 14
        }

        Item {
            anchors.fill: parent

            Rectangle {
                id: slider

                readonly property real slotW: (parent.width - (root.tabs.length + 1) * 4) / root.tabs.length

                width: slotW
                height: parent.height - 8
                anchors.verticalCenter: parent.verticalCenter
                x: 4 + root.tabs.indexOf(root.currentTab) * (slotW + 4)
                radius: 7
                color: Theme.primaryContainer
                border.width: 1
                border.color: Theme.outlineVariant

                Behavior on x {
                    NumberAnimation {
                        duration: 380
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.4
                    }

                }

            }

            Row {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4

                Repeater {
                    model: root.tabs

                    delegate: Item {
                        id: tabBtn

                        required property string modelData
                        required property int index

                        width: (parent.width - (root.tabs.length - 1) * 4) / root.tabs.length
                        height: parent.height

                        Text {
                            anchors.centerIn: parent
                            text: tabBtn.modelData
                            font.pixelSize: 15
                            font.family: "CaskaydiaCove NF"
                            font.weight: root.currentTab === tabBtn.modelData ? Font.Medium : Font.Normal
                            color: root.currentTab === tabBtn.modelData ? Theme.onPrimaryContainer : Theme.onSurfaceVariant

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = tabBtn.modelData
                        }

                    }

                }

            }

        }

    }

    GridView {
        cellWidth: width / 5
        cellHeight: 95
        clip: true
        model: charModel
        boundsBehavior: Flickable.DragAndOvershootBounds

        anchors {
            top: tabBar.bottom
            topMargin: 10
            bottom: parent.bottom
            bottomMargin: 0
            left: parent.left
            right: parent.right
        }

        delegate: Item {
            id: gridItem

            required property string kanji
            required property string meaning

            width: GridView.view.cellWidth
            height: GridView.view.cellHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                color: Theme.surfaceContainerHighest
                radius: 10
                opacity: 0.85

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gridItem.kanji
                        color: Theme.onSurface
                        font.pixelSize: 38
                        font.family: "Noto Sans CJK JP"
                        font.weight: Font.Medium
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gridItem.meaning
                        color: Theme.onSurfaceVariant
                        font.pixelSize: 10
                    }

                }

            }

        }

    }

}
