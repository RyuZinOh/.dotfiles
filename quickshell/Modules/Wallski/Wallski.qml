import QtQuick
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import qs.Data as Dat
import qs.Services.Theme
import qs.Services.Shapes

Item {
    id: root
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter

    width: content.width
    height: content.height

    property bool isHovered: false
    property bool isRefreshing: false

    readonly property string thumbsPath: "file:///home/safal726/thumbs/"
    readonly property string picturesPath: "/home/safal726/Pictures/"

    signal wallpaperChanged(string path)

    onIsHoveredChanged: {
        if (!isHovered) {
            unloadTimer.start();
        } else {
            unloadTimer.stop();
            if (!contentLoader.active) {
                contentLoader.active = true;
            }
        }
    }

    Timer {
        id: unloadTimer
        interval: 400
        onTriggered: {
            if (!root.isHovered) {
                folderModel.nameFilters = ["*.jpg", "*.jpeg"];
                contentLoader.active = false;
            }
        }
    }

    Process {
        id: bamProcess
        command: ["/bin/bash", "/home/safal726/.dotfiles/quickshell/Scripts/bam.sh"]
        running: false
        onExited: isRefreshing = false
    }

    PopoutShape {
        id: content
        width: contentLoader.item ? contentLoader.item.implicitWidth + 20 : 1200
        height: isHovered ? (contentLoader.item ? contentLoader.item.implicitHeight + 40 : 235) : 0.1
        alignment: 4
        radius: 20
        color: Theme.surfaceContainerLow
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
            anchors {
                leftMargin: 10
                rightMargin: 10
                topMargin: 10
                bottomMargin: 10
            }
            active: false
            asynchronous: true

            onLoaded: {
                if (item && item.searchInput) {
                    item.searchInput.text = "";
                }
                if (item && item.listView && Dat.WallpaperConfigAdapter.currentWallpaper) {
                    Qt.callLater(function () {
                        const currentFilename = Dat.WallpaperConfigAdapter.currentWallpaper.split('/').pop();
                        for (let i = 0; i < folderModel.count; i++) {
                            if (folderModel.get(i, "fileName") === currentFilename) {
                                item.listView.currentIndex = i;
                                item.listView.positionViewAtIndex(i, ListView.Center);
                                break;
                            }
                        }
                        item.listView.focus = true;
                    });
                }
            }

            sourceComponent: Item {
                id: contentItem
                visible: root.isHovered
                implicitWidth: 1180
                implicitHeight: 204

                property alias searchInput: searchInput
                property alias listView: listView

                Column {
                    id: mainColumn
                    anchors.fill: parent
                    spacing: 10

                    Item {
                        width: parent.width
                        height: 150

                        ListView {
                            id: listView
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            model: folderModel
                            orientation: ListView.Horizontal
                            spacing: 0
                            interactive: false
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: 0
                            preferredHighlightBegin: width / 2 - 115
                            preferredHighlightEnd: width / 2 + 115
                            highlightRangeMode: ListView.StrictlyEnforceRange
                            clip: false

                            opacity: root.isHovered ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_I) {
                                    searchInput.focus = true;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_J || event.key === Qt.Key_Left) {
                                    decrementCurrentIndex();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_K || event.key === Qt.Key_Right) {
                                    incrementCurrentIndex();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    applyWallpaper(currentIndex);
                                    event.accepted = true;
                                }
                            }

                            delegate: Item {
                                required property string fileName
                                required property int index

                                width: 230
                                height: 150

                                property bool isCurrent: index === listView.currentIndex

                                opacity: root.isHovered ? 1 : 0
                                scale: root.isHovered ? 1 : 0.95

                                Behavior on opacity {
                                    SequentialAnimation {
                                        PauseAnimation {
                                            duration: Math.abs(index - listView.currentIndex) * 30
                                        }
                                        NumberAnimation {
                                            duration: 300
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }

                                Behavior on scale {
                                    SequentialAnimation {
                                        PauseAnimation {
                                            duration: Math.abs(index - listView.currentIndex) * 30
                                        }
                                        NumberAnimation {
                                            duration: 300
                                            easing.type: Easing.OutBack
                                            easing.overshoot: 1.1
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    radius: 16
                                    border.width: isCurrent ? 2 : 0
                                    border.color: Theme.primaryColor

                                    Item {
                                        id: imageContainer
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        layer.enabled: true
                                        layer.effect: OpacityMask {
                                            maskSource: Rectangle {
                                                width: imageContainer.width
                                                height: imageContainer.height
                                                radius: 14
                                            }
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            color: Theme.surfaceContainerHighest

                                            Image {
                                                anchors.fill: parent
                                                source: root.thumbsPath + fileName
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                asynchronous: true
                                                cache: false
                                            }
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            color: Theme.scrimColor
                                            opacity: isCurrent ? 0.7 : 0

                                            Behavior on opacity {
                                                NumberAnimation {
                                                    duration: 350
                                                    easing.type: Easing.OutCubic
                                                }
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: fileName.replace(/\.[^/.]+$/, "").replace(/_/g, " ")
                                                color: Theme.inverseOnSurface
                                                font.pixelSize: 13
                                                font.family: "CaskaydiaCove NF"
                                                font.weight: Font.Medium
                                                elide: Text.ElideMiddle
                                                width: parent.width - 24
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }
                                }
                            }

                            onCurrentIndexChanged: {
                                positionViewAtIndex(currentIndex, ListView.Center);
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12
                            visible: folderModel.count === 0

                            opacity: root.isHovered ? 1 : 0
                            scale: root.isHovered ? 1 : 0.95

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.1
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: searchInput.text ? `No results for "${searchInput.text}"` : "No wallpapers found"
                                color: Theme.onSurface
                                font.pixelSize: 15
                                font.family: "CaskaydiaCove NF"
                                font.weight: Font.Medium
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: searchInput.text ? "Try a different search term" : "Add images to ~/Pictures/"
                                color: Theme.onSurfaceVariant
                                font.pixelSize: 13
                                font.family: "CaskaydiaCove NF"
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: 44

                        Row {
                            anchors.fill: parent
                            spacing: 8

                            Rectangle {
                                id: searchBar
                                anchors.verticalCenter: parent.verticalCenter
                                width: 280
                                height: 40
                                radius: 12
                                color: Theme.surfaceContainerHigh
                                border.width: 1
                                border.color: searchInput.activeFocus ? Theme.primaryColor : Theme.outlineVariant

                                Behavior on border.color {
                                    ColorAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 12

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "\uedfb"
                                        font.pixelSize: 16
                                        font.family: "CaskaydiaCove NF"
                                        color: searchInput.activeFocus ? Theme.primaryColor : Theme.onSurfaceVariant

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 200
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }

                                    TextInput {
                                        id: searchInput
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 52
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: Theme.onSurface
                                        font.pixelSize: 14
                                        font.family: "CaskaydiaCove NF"
                                        clip: true
                                        selectByMouse: true
                                        selectionColor: Theme.primaryContainer

                                        Keys.onPressed: event => {
                                            if (event.key === Qt.Key_Escape) {
                                                searchInput.focus = false;
                                                listView.focus = true;
                                                event.accepted = true;
                                            }
                                        }

                                        Text {
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            text: `Search among ${folderModel.count} wallpapers`
                                            color: Theme.onSurfaceVariant
                                            visible: !searchInput.text && !searchInput.activeFocus
                                            font.pixelSize: 13
                                            font.family: "CaskaydiaCove NF"
                                        }

                                        onTextChanged: {
                                            const query = text.toLowerCase().trim();
                                            folderModel.nameFilters = query ? [`*${query}*.jpg`, `*${query}*.jpeg`] : ["*.jpg", "*.jpeg"];
                                        }
                                    }

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: "transparent"
                                        visible: searchInput.text !== ""

                                        Text {
                                            anchors.centerIn: parent
                                            text: "×"
                                            color: Theme.primaryColor
                                            font.pixelSize: 14
                                            font.family: "CaskaydiaCove NF"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: searchInput.text = ""
                                        }
                                    }
                                }
                            }

                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 280 - 44 - 24
                                height: 32
                                clip: true

                                Flow {
                                    anchors.fill: parent
                                    spacing: 6

                                    Repeater {
                                        model: Theme.schemeTypes

                                        Item {
                                            required property string modelData
                                            property bool isActive: Theme.currentSchemeType === modelData

                                            height: 32
                                            width: tagRect.width

                                            Rectangle {
                                                id: activeIndicator
                                                anchors.fill: parent
                                                radius: 16
                                                color: Theme.primaryContainer
                                                visible: isActive

                                                scale: isActive ? 1 : 0.9
                                                opacity: isActive ? 1 : 0

                                                Behavior on scale {
                                                    NumberAnimation {
                                                        duration: 300
                                                        easing.type: Easing.OutBack
                                                        easing.overshoot: 1.2
                                                    }
                                                }

                                                Behavior on opacity {
                                                    NumberAnimation {
                                                        duration: 200
                                                        easing.type: Easing.OutCubic
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                id: tagRect
                                                anchors.fill: parent
                                                width: schemeText.width + 20
                                                radius: isActive ? 16 : 6
                                                color: isActive ? "transparent" : (schemeTagMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)

                                                Behavior on radius {
                                                    NumberAnimation {
                                                        duration: 400
                                                        easing.type: Easing.InOutCubic
                                                    }
                                                }

                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: 300
                                                        easing.type: Easing.OutCubic
                                                    }
                                                }

                                                Text {
                                                    id: schemeText
                                                    anchors.centerIn: parent
                                                    text: Theme.getSchemeDisplayName(modelData)
                                                    color: isActive ? Theme.onPrimaryContainer : Theme.onSurface
                                                    font.pixelSize: 12
                                                    font.family: "CaskaydiaCove NF"
                                                    font.weight: isActive ? Font.Medium : Font.Normal
                                                    z: 1

                                                    Behavior on color {
                                                        ColorAnimation {
                                                            duration: 300
                                                            easing.type: Easing.OutCubic
                                                        }
                                                    }
                                                }

                                                MouseArea {
                                                    id: schemeTagMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: Theme.setSchemeType(modelData)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 44
                                height: 44
                                radius: 12
                                color: refreshMouse.containsMouse ? Theme.primaryContainer : Theme.surfaceContainerHigh

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰑐"
                                    color: refreshMouse.containsMouse ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                                    font.pixelSize: 20
                                    font.family: "CaskaydiaCove NF"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    RotationAnimator on rotation {
                                        from: 0
                                        to: 360
                                        duration: 500
                                        loops: Animation.Infinite
                                        running: isRefreshing
                                    }
                                }

                                MouseArea {
                                    id: refreshMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: !isRefreshing
                                    onClicked: {
                                        isRefreshing = true;
                                        bamProcess.running = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            root.isHovered = hovered;
        }
    }

    FolderListModel {
        id: folderModel
        folder: root.thumbsPath
        nameFilters: ["*.jpg", "*.jpeg"]
        showDirs: false
    }

    function applyWallpaper(index) {
        const fileName = folderModel.get(index, "fileName");
        const fullPath = root.picturesPath + fileName;
        const fileUrl = "file://" + fullPath;
        const thumbPath = root.thumbsPath + fileName;

        Theme.thumbPath = thumbPath;
        Theme.saveTheme();

        // set wallpaper via IPC
        setWallpaperProcess.command = ["quickshell", "ipc", "call", "wallpaper", "setWallpaper", fullPath];
        setWallpaperProcess.running = true;

        // copy wallpaper to cache
        copyProcess.command = ["/usr/bin/sh", "-c", `mkdir -p /home/safal726/.cache/safalQuick/ && cp "${fullPath}" /home/safal726/.cache/safalQuick/bg.jpg`];
        copyProcess.running = true;

        // notify user
        const wallpaperName = fileName.replace(/\.[^/.]+$/, "").replace(/_/g, " ");
        notifyProcess.command = ["/usr/bin/notify-send", "--app-name=Wallski", "✓ Wallpaper Applied", wallpaperName];
        notifyProcess.running = true;

        root.wallpaperChanged(fullPath);
    }

    Process {
        id: notifyProcess
    }
    Process {
        id: copyProcess
    }
    Process {
        id: setWallpaperProcess
    }
}
