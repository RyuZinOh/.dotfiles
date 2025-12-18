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
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        width: root.isHovered ? 375 : 0.1
        height: parent.height
        style: 1
        alignment: 2
        radius: 20
        color: Theme.surfaceContainer

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
            visible: root.isHovered
            opacity: root.isHovered ? 1 : 0
            scale: root.isHovered ? 1 : 0.85

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                // Header Row
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    Row {
                        id: tabRow
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 25

                        Repeater {
                            id: tabRepeater
                            model: ["Anime List", "To-Do"]

                            Item {
                                width: tabText.width + 10
                                height: 28

                                property bool isActive: currentTab === index

                                Text {
                                    id: tabText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: parent.isActive ? Theme.onSurface : Theme.dimColor
                                    font.pixelSize: 13
                                    font.weight: parent.isActive ? Font.Medium : Font.Normal
                                    font.family: "CaskaydiaCove NF"
                                    opacity: parent.isActive ? 1.0 : 0.5

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

                    // Refresh Button
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        radius: width / 2
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            color: Theme.onSurface
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
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                spinAnimation.start();
                                readProcess.running = true;
                            }
                        }
                    }

                    Rectangle {
                        height: 2
                        color: Theme.primaryColor

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
                        active: root.isHovered
                        sourceComponent: currentTab === 0 ? animeComponent : todoComponent
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
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: animeModel
                spacing: 6

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 36
                    color: Theme.surfaceColor
                    radius: 10
                    border.width: 1
                    border.color: Theme.outlineVariant

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: model.name
                            color: Theme.onSurface
                            font.pixelSize: 14
                            font.family: "CaskaydiaCove NF"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 4
                            color: deleteMouseArea.containsMouse ? Theme.errorContainer : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: deleteMouseArea.containsMouse ? Theme.onErrorContainer : Theme.tertiaryColor
                                font.pixelSize: 14
                                font.family: "CaskaydiaCove NF"
                            }

                            MouseArea {
                                id: deleteMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    animeModel.remove(index);
                                    saveData();
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
                    id: animeInputField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    placeholderText: "Add anime..."
                    placeholderTextColor: Theme.dimColor
                    color: Theme.onSurface
                    font.pixelSize: 13
                    font.family: "CaskaydiaCove NF"
                    leftPadding: 12
                    rightPadding: 12

                    background: Rectangle {
                        color: Theme.surfaceColor
                        radius: 100
                        border.width: 1
                        border.color: animeInputField.activeFocus ? Theme.primaryColor : Theme.outlineVariant
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
                    Layout.preferredHeight: 36

                    contentItem: Text {
                        text: parent.text
                        color: Theme.onPrimary
                        font.pixelSize: 13
                        font.family: "CaskaydiaCove NF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: Theme.primaryColor
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
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: todoModel
                spacing: 6

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 36
                    color: Theme.surfaceColor
                    radius: 10
                    border.width: 1
                    border.color: Theme.outlineVariant

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: model.name
                            color: Theme.onSurface
                            font.pixelSize: 14
                            font.family: "CaskaydiaCove NF"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 4
                            color: deleteMouseArea.containsMouse ? Theme.errorContainer : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: deleteMouseArea.containsMouse ? Theme.onErrorContainer : Theme.tertiaryColor
                                font.pixelSize: 14
                                font.family: "CaskaydiaCove NF"
                            }

                            MouseArea {
                                id: deleteMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    todoModel.remove(index);
                                    saveData();
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TextField {
                    id: todoInputField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    placeholderText: "Add task..."
                    placeholderTextColor: Theme.dimColor
                    color: Theme.onSurface
                    font.pixelSize: 13
                    font.family: "CaskaydiaCove NF"
                    leftPadding: 12
                    rightPadding: 12

                    background: Rectangle {
                        color: Theme.surfaceColor
                        radius: 100
                        border.width: 1
                        border.color: todoInputField.activeFocus ? Theme.primaryColor : Theme.outlineVariant
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
                    Layout.preferredHeight: 36

                    contentItem: Text {
                        text: parent.text
                        color: Theme.onPrimary
                        font.pixelSize: 13
                        font.family: "CaskaydiaCove NF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: Theme.primaryColor
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
                                if (name)
                                    animeModel.append({
                                        "name": name
                                    });
                            });
                        }

                        todoModel.clear();
                        if (json.todo && Array.isArray(json.todo)) {
                            json.todo.forEach(name => {
                                if (name)
                                    todoModel.append({
                                        "name": name
                                    });
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
