import QtQuick
import QtQuick.Layouts
import Kraken
import qs.Services.Theme
import Quickshell.Io

Item {
    id: root
    width: 375
    height: 350

    property int currentTab: 0
    readonly property string malFile: "/home/safal726/.cache/safalQuick/mal.json"

    ListModel {
        id: animeModel
    }

    ListModel {
        id: todoModel
    }

    Kraken {
        id: malReader
        filePath: root.malFile
        onDataLoaded: {
            animeModel.clear();
            if (malReader.data.anime) {
                const animeArray = malReader.data.anime;
                for (let i = 0; i < animeArray.length; i++) {
                    const name = animeArray[i];
                    if (name) {
                        animeModel.append({
                            "name": name
                        });
                    }
                }
            }
            todoModel.clear();
            if (malReader.data.todo) {
                const todoArray = malReader.data.todo;
                for (let i = 0; i < todoArray.length; i++) {
                    const name = todoArray[i];
                    if (name) {
                        todoModel.append({
                            "name": name
                        });
                    }
                }
            }
        }
        onLoadFailed: function (error) {
            animeModel.clear();
            todoModel.clear();
        }
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
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.radius
                    color: parent.color
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: currentTab === 0 ? Theme.primaryContainer : "transparent"
                        radius: 8
                        border.width: currentTab === 0 ? 1 : 0
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
                            text: "Anime"
                            color: currentTab === 0 ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                            font.pixelSize: 14
                            font.family: "CaskaydiaCove NF"
                            font.weight: currentTab === 0 ? Font.Medium : Font.Normal

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentTab = 0;
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: currentTab === 1 ? Theme.primaryContainer : "transparent"
                        radius: 8
                        border.width: currentTab === 1 ? 1 : 0
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
                            text: "Tasks"
                            color: currentTab === 1 ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                            font.pixelSize: 14
                            font.family: "CaskaydiaCove NF"
                            font.weight: currentTab === 1 ? Font.Medium : Font.Normal

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentTab = 1;
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.outlineVariant
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Item {
                    id: contentContainer
                    anchors.fill: parent
                    clip: true

                    Item {
                        id: slidingContent
                        width: parent.width * 2
                        height: parent.height
                        x: -currentTab * parent.width

                        Behavior on x {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }

                        Loader {
                            id: animeLoader
                            width: contentContainer.width
                            height: parent.height
                            x: 0
                            sourceComponent: animeComponent
                        }

                        Loader {
                            id: todoLoader
                            width: contentContainer.width
                            height: parent.height
                            x: contentContainer.width
                            sourceComponent: todoComponent
                        }
                    }
                }
            }
        }
    }

    Component {
        id: animeComponent

        ColumnLayout {
            spacing: 0
            anchors.fill: parent
            anchors.margins: 12

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: animeModel
                spacing: 8

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 48
                    color: Theme.surfaceContainer
                    radius: 12
                    border.width: 1
                    border.color: Theme.outlineVariant

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                            text: model.name
                            color: Theme.onSurface
                            font.pixelSize: 14
                            font.family: "CaskaydiaCove NF"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            Layout.alignment: Qt.AlignVCenter
                            radius: deleteHoverHandler.hovered ? 16 : 6
                            color: Theme.primaryColor
                            border.width: 1
                            border.color: Theme.outlineVariant

                            Behavior on radius {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: Theme.onPrimary
                                font.pixelSize: 16
                                font.family: "CaskaydiaCove NF"
                            }

                            HoverHandler {
                                id: deleteHoverHandler
                                cursorShape: Qt.PointingHandCursor
                            }

                            MouseArea {
                                anchors.fill: parent
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
                        color: refreshHoverHandler.hovered ? Theme.surfaceContainerHigh : Theme.surfaceContainer
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
                            font.pixelSize: 18
                            font.family: "CaskaydiaCove NF"

                            RotationAnimator on rotation {
                                id: spinAnimation
                                from: 0
                                to: 360
                                duration: 600
                                loops: 1
                            }
                        }

                        HoverHandler {
                            id: refreshHoverHandler
                            cursorShape: Qt.PointingHandCursor
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                spinAnimation.start();
                                malReader.reload();
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        Layout.alignment: Qt.AlignVCenter
                        color: Theme.surfaceContainerHigh
                        radius: 24
                        border.width: animeInputField.activeFocus ? 2 : 1
                        border.color: animeInputField.activeFocus ? Theme.primaryColor : Theme.outlineVariant

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
                            id: animeInputField
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.onSurface
                            font.pixelSize: 14
                            font.family: "CaskaydiaCove NF"
                            clip: true

                            Text {
                                visible: !animeInputField.text && !animeInputField.activeFocus
                                text: "Add anime..."
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 14
                                font.family: "CaskaydiaCove NF"
                                anchors.verticalCenter: parent.verticalCenter
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

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                animeInputField.forceActiveFocus();
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: todoComponent

        ColumnLayout {
            spacing: 0
            anchors.fill: parent
            anchors.margins: 12

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: todoModel
                spacing: 8

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 48
                    color: Theme.surfaceContainer
                    radius: 12
                    border.width: 1
                    border.color: Theme.outlineVariant

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                            text: model.name
                            color: Theme.onSurface
                            font.pixelSize: 14
                            font.family: "CaskaydiaCove NF"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            Layout.alignment: Qt.AlignVCenter
                            radius: deleteTodoHoverHandler.hovered ? 16 : 6
                            color: Theme.primaryColor
                            border.width: 1
                            border.color: Theme.outlineVariant

                            Behavior on radius {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: Theme.onPrimary
                                font.pixelSize: 16
                                font.family: "CaskaydiaCove NF"
                            }

                            HoverHandler {
                                id: deleteTodoHoverHandler
                                cursorShape: Qt.PointingHandCursor
                            }

                            MouseArea {
                                anchors.fill: parent
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
                        color: refreshTodoHoverHandler.hovered ? Theme.surfaceContainerHigh : Theme.surfaceContainer
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
                            font.pixelSize: 18
                            font.family: "CaskaydiaCove NF"

                            RotationAnimator on rotation {
                                id: spinTodoAnimation
                                from: 0
                                to: 360
                                duration: 600
                                loops: 1
                            }
                        }

                        HoverHandler {
                            id: refreshTodoHoverHandler
                            cursorShape: Qt.PointingHandCursor
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                spinTodoAnimation.start();
                                malReader.reload();
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        Layout.alignment: Qt.AlignVCenter
                        color: Theme.surfaceContainerHigh
                        radius: 24
                        border.width: todoInputField.activeFocus ? 2 : 1
                        border.color: todoInputField.activeFocus ? Theme.primaryColor : Theme.outlineVariant

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
                            id: todoInputField
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.onSurface
                            font.pixelSize: 14
                            font.family: "CaskaydiaCove NF"
                            clip: true

                            Text {
                                visible: !todoInputField.text && !todoInputField.activeFocus
                                text: "Add task..."
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 14
                                font.family: "CaskaydiaCove NF"
                                anchors.verticalCenter: parent.verticalCenter
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

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.IBeamCursor
                            onClicked: {
                                todoInputField.forceActiveFocus();
                            }
                        }
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
        id: saveProcess
    }
}
