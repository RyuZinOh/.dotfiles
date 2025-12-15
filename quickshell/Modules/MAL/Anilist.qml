import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Services.Shapes
import qs.Services.Theme
import Quickshell.Io

Item {
    id: root
    width: content.width
    height: 350
    property bool isHovered: false
    property int currentTab: 0 //tabbing method

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
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        width: root.isHovered ? 375 : 0.1
        height: parent.height

        style: 1
        alignment: 6
        radius: 20
        color: Theme.colors.surface_container

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
                spacing: 8

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
                            color: Theme.colors.on_surface
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

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    Row {
                        id: tabRow
                        anchors.fill: parent
                        spacing: 25

                        Repeater {
                            id: tabRepeater
                            model: ["Anime List", "To-Do"]

                            Item {
                                id: tabItem
                                width: tabText.width + 10
                                height: 28

                                property bool isActive: currentTab === index

                                Text {
                                    id: tabText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: tabItem.isActive ? Theme.colors.on_surface : Theme.colors.outline
                                    font.pixelSize: 13
                                    font.weight: tabItem.isActive ? Font.Medium : Font.Normal
                                    font.family: "CaskaydiaCove NF"
                                    opacity: tabItem.isActive ? 1.0 : 0.5

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 200
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: currentTab = index
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: activeIndicator
                        height: 2
                        color: Theme.colors.primary

                        property Item activeTab: tabRepeater.count > 0 ? tabRepeater.itemAt(currentTab) : null

                        x: activeTab ? activeTab.x + (activeTab.width - width) / 2 : 0
                        width: activeTab ? activeTab.width : 0

                        Behavior on x {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on width {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                // Content Area
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Loader {
                        id: contentLoader
                        anchors.fill: parent
                        opacity: 0
                        sourceComponent: {
                            switch (currentTab) {
                            case 0:
                                return animeComponent;
                            case 1:
                                return todoComponent;
                            default:
                                return null;
                            }
                        }
                        onLoaded: fadeInAnimation.restart()

                        NumberAnimation {
                            id: fadeInAnimation
                            target: contentLoader
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 250
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: root.isHovered = hovered
    }

    // Anime List Component
    Component {
        id: animeComponent

        ColumnLayout {
            spacing: 8

            ListView {
                id: animeListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: animeModel

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 32
                    color: Theme.colors.surface
                    radius: 10

                    RowLayout {
                        anchors.fill: parent

                        Text {
                            text: " " + model.name
                            color: Theme.colors.on_surface
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
                                color: Theme.colors.tertiary
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: "transparent"
                            }

                            onClicked: {
                                animeModel.remove(index);
                                saveData();
                            }

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
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
                    id: animeInputField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    placeholderText: "Add anime..."
                    placeholderTextColor: Theme.colors.outline
                    color: Theme.colors.on_surface
                    font.pixelSize: 13
                    font.family: "CaskaydiaCove NF"
                    leftPadding: 10
                    rightPadding: 10

                    background: Rectangle {
                        color: Theme.colors.surface
                        radius: 100
                    }

                    Keys.onReturnPressed: {
                        const text = animeInputField.text.trim();
                        if (text.length > 0) {
                            animeModel.append({
                                "name": text
                            });
                            animeInputField.text = "";
                            saveData();
                        }
                    }
                }

                Button {
                    text: "Add"
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 32

                    contentItem: Text {
                        text: parent.text
                        color: Theme.colors.on_primary
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: Theme.colors.primary
                        radius: 100
                    }

                    onClicked: {
                        const text = animeInputField.text.trim();
                        if (text.length > 0) {
                            animeModel.append({
                                "name": text
                            });
                            animeInputField.text = "";
                            saveData();
                        }
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    // To-Do Component
    Component {
        id: todoComponent

        ColumnLayout {
            spacing: 8

            ListView {
                id: todoListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: todoModel

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 32
                    color: Theme.colors.surface
                    radius: 10

                    RowLayout {
                        anchors.fill: parent
                        Text {
                            text: " " + model.name
                            color: Theme.colors.on_surface
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
                                color: Theme.colors.tertiary
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: "transparent"
                            }

                            onClicked: {
                                todoModel.remove(index);
                                saveData();
                            }

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
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
                    id: todoInputField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    placeholderText: "Add task..."
                    placeholderTextColor: Theme.colors.outline
                    color: Theme.colors.on_surface
                    font.pixelSize: 13
                    font.family: "CaskaydiaCove NF"
                    leftPadding: 10
                    rightPadding: 10

                    background: Rectangle {
                        color: Theme.colors.surface
                        radius: 100
                    }

                    Keys.onReturnPressed: {
                        const text = todoInputField.text.trim();
                        if (text.length > 0) {
                            todoModel.append({
                                "name": text
                            });
                            todoInputField.text = "";
                            saveData();
                        }
                    }
                }

                Button {
                    text: "Add"
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 32

                    contentItem: Text {
                        text: parent.text
                        color: Theme.colors.on_primary
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: Theme.colors.primary
                        radius: 100
                    }

                    onClicked: {
                        const text = todoInputField.text.trim();
                        if (text.length > 0) {
                            todoModel.append({
                                "name": text
                            });
                            todoInputField.text = "";
                            saveData();
                        }
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
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
