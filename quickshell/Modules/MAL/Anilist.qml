import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Services.Shapes
import Quickshell.Io

Item {
    id: root
    width: content.width
    height: 350
    property bool isHovered: false

    // anime or to_do
    property string currentTab: "anime"

    readonly property color bg: "black"
    readonly property color textPrimary: "white"
    readonly property color accent: "blue"
    readonly property string malFile: "/home/safal726/.cache/safalQuick/mal.json"

    // anime and todomodel
    ListModel {
        id: animeModel
    }
    ListModel {
        id: todoModel
    }

    focus: true

    PopoutShape {
        id: content
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        width: root.isHovered ? 375 : 0.1
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

        // Inner Content
        Item {
            anchors.fill: parent
            anchors.margins: 20
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

                // Header Row
                RowLayout {
                    Layout.fillWidth: true

                    Item {
                        Layout.fillWidth: true
                    }

                    // Refresh Button
                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: width / 2
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            color: "white"
                            font.pixelSize: 16
                            font.family: "CaskaydiaCove NF"
                            RotationAnimator on rotation {
                                id: spinAnimation
                                from: 0
                                to: 360
                                duration: 600
                                loops: 1
                            }
                        }
                        MouseArea {
                            id: reloadMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                spinAnimation.start();
                                readProcess.running = true;
                            }
                        }
                    }
                }

                // Tabs (Anime / To-Do)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Anime Tab
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: root.currentTab === "anime" ? root.accent : "#202020"
                        radius: 100

                        Text {
                            anchors.centerIn: parent
                            text: "Anime List"
                            color: root.currentTab === "anime" ? "black" : "white"
                            font.family: "CaskaydiaCove NF"
                            font.pixelSize: 14
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = "anime"
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    // to_do Tab
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: root.currentTab === "todo" ? root.accent : "#202020"
                        radius: 100

                        Text {
                            anchors.centerIn: parent
                            text: "To-Do"
                            color: root.currentTab === "todo" ? "black" : "white"
                            font.family: "CaskaydiaCove NF"
                            font.pixelSize: 14
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = "todo"
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }
                }

                // List View
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ListView {
                        id: mainListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        model: root.currentTab === "anime" ? animeModel : todoModel

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 32
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent

                                Text {
                                    text: model.name
                                    color: root.textPrimary
                                    font.pixelSize: 14
                                    font.family: "CaskaydiaCove NF"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Button {
                                    text: ""
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 26

                                    contentItem: Text {
                                        text: parent.text
                                        color: "red"
                                        font.pixelSize: 14
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    onClicked: {
                                        if (root.currentTab === "anime") {
                                            animeModel.remove(index);
                                        } else {
                                            todoModel.remove(index);
                                        }
                                        saveData();
                                    }

                                    HoverHandler {
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }
                    }
                }

                // Input Area
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: inputField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        placeholderText: root.currentTab === "anime" ? "Add anime..." : "Add task..."
                        placeholderTextColor: "white"
                        color: root.textPrimary
                        font.pixelSize: 13
                        font.family: "CaskaydiaCove NF"
                        leftPadding: 10
                        rightPadding: 10

                        background: Rectangle {
                            color: "#202020"
                            radius: 100
                        }

                        Keys.onReturnPressed: addItem()
                    }

                    Button {
                        text: "Add"
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 32

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: "blue"
                            radius: 100
                        }

                        onClicked: addItem()
                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: root.isHovered = hovered
    }

    function addItem() {
        const text = inputField.text.trim();
        if (text.length > 0) {
            if (root.currentTab === "anime") {
                animeModel.append({
                    "name": text
                });
            } else {
                todoModel.append({
                    "name": text
                });
            }
            inputField.text = "";
            saveData();
        }
    }

    function saveData() {
        const animeList = [];
        for (let i = 0; i < animeModel.count; i++) {
            animeList.push(animeModel.get(i).name);
        }

        const todoList = [];
        for (let j = 0; j < todoModel.count; j++) {
            todoList.push(todoModel.get(j).name);
        }

        const finalObj = {
            "anime": animeList,
            "todo": todoList
        };

        const jsonString = JSON.stringify(finalObj);
        const escaped = jsonString.replace(/'/g, "'\\''");

        saveProcess.command = ["/bin/sh", "-c", `mkdir -p "$(dirname "${malFile}")" && echo '${escaped}' > "${malFile}"`];
        saveProcess.running = true;
    }

    Process {
        id: readProcess
        command: ["/bin/sh", "-c", `mkdir -p "$(dirname "${malFile}")" && (cat "${malFile}" 2>/dev/null || echo '{"anime":[], "todo":[]}')`]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const content = data.trim();
                if (content) {
                    try {
                        const json = JSON.parse(content);

                        animeModel.clear();
                        if (json.anime && Array.isArray(json.anime)) {
                            json.anime.forEach(name => {
                                if (name) {
                                    animeModel.append({
                                        "name": name
                                    });
                                }
                            });
                        }

                        todoModel.clear();
                        if (json.todo && Array.isArray(json.todo)) {
                            json.todo.forEach(name => {
                                if (name) {
                                    todoModel.append({
                                        "name": name
                                    });
                                }
                            });
                        }
                    } catch (e) {
                        console.log("JSON parse error:", e);
                    }
                }
            }
        }
    }

    Process {
        id: saveProcess
    }
}
