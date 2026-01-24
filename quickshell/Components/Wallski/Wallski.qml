pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import Quickshell
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

    HoverHandler {
        onHoveredChanged: {
            if (hovered) {
                unloadTimer.stop();
                contentLoader.active = true;
            } else {
                unloadTimer.restart();
                resetFilter();
            }
            root.isHovered = hovered;
        }
    }

    Timer {
        id: unloadTimer
        interval: 400
        onTriggered: contentLoader.active = false
    }

    Process {
        id: bamProcess
        command: ["/bin/bash", "/home/safal726/.dotfiles/quickshell/Scripts/bam.sh"]
        running: false
        onExited: {
            isRefreshing = false;
            folderModel.folder = root.thumbsPath;
        }
    }

    PopoutShape {
        id: content
        width: 1600
        height: isHovered ? 364 : 0.1
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
            anchors.margins: 12
            active: false
            asynchronous: true
            visible: false

            onLoaded: {
                visible = false;
                positionTimer.start();
            }

            Timer {
                id: positionTimer
                interval: 50
                onTriggered: {
                    positionToCurrentWallpaper();
                    contentLoader.visible = true;
                }
            }

            sourceComponent: Item {
                id: contentItem

                readonly property alias listView: listView

                Column {
                    anchors.fill: parent
                    spacing: 16

                    Item {
                        width: parent.width
                        height: 260

                        ListView {
                            id: listView
                            anchors.fill: parent
                            model: folderModel
                            orientation: ListView.Horizontal
                            spacing: 10
                            highlightMoveDuration: 0
                            preferredHighlightBegin: width / 2 - 160
                            preferredHighlightEnd: width / 2 + 160
                            highlightRangeMode: ListView.StrictlyEnforceRange
                            clip: true
                            cacheBuffer: 960
                            interactive: false

                            onCurrentIndexChanged: {
                                if (contentLoader.visible) {
                                    highlightMoveDuration = 300;
                                }
                            }

                            Rectangle {
                                width: 320
                                height: 260
                                anchors.centerIn: parent
                                color: "transparent"
                                radius: 14
                                border.width: 3
                                border.color: Theme.primaryColor
                                z: 100
                            }

                            delegate: Item {
                                id: delegateRoot
                                required property string fileName
                                required property int index

                                width: 320
                                height: 260

                                readonly property bool isCurrent: index === ListView.view.currentIndex

                                Item {
                                    anchors.fill: parent
                                    layer.enabled: true
                                    layer.effect: OpacityMask {
                                        maskSource: Rectangle {
                                            width: 320
                                            height: 260
                                            radius: 14
                                        }
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.surfaceContainerHighest

                                        Image {
                                            anchors.fill: parent
                                            source: root.thumbsPath + delegateRoot.fileName
                                            fillMode: Image.PreserveAspectCrop
                                            smooth: true
                                            asynchronous: true
                                            cache: true
                                        }
                                    }

                                    Rectangle {
                                        visible: delegateRoot.isCurrent
                                        anchors.fill: parent
                                        color: "black"
                                        opacity: 0.7

                                        Text {
                                            anchors.centerIn: parent
                                            text: delegateRoot.fileName.replace(/\.[^/.]+$/, "").replace(/_/g, " ")
                                            color: "white"
                                            font.pixelSize: 13
                                            font.family: "CaskaydiaCove NF"
                                            font.weight: Font.Medium
                                            elide: Text.ElideMiddle
                                            width: parent.width - 48
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: delegateRoot.isCurrent ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    enabled: delegateRoot.isCurrent
                                    onClicked: applyWallpaper(delegateRoot.index)
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            z: -1
                            acceptedButtons: Qt.NoButton

                            property real accumulatedDelta: 0
                            readonly property int threshold: 50

                            onWheel: wheel => {
                                const deltaX = wheel.pixelDelta.x;
                                if (deltaX === 0)
                                    return;

                                accumulatedDelta -= deltaX;

                                if (Math.abs(accumulatedDelta) >= threshold) {
                                    if (accumulatedDelta > 0) {
                                        listView.incrementCurrentIndex();
                                    } else {
                                        listView.decrementCurrentIndex();
                                    }
                                    accumulatedDelta = 0;
                                }
                                wheel.accepted = true;
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12
                            visible: folderModel.count === 0

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
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Rectangle {
                                width: 320
                                height: 44
                                radius: 12
                                color: Theme.surfaceContainerHigh
                                border.width: 1
                                border.color: searchInput.activeFocus ? Theme.primaryColor : Theme.outlineVariant

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 18
                                    anchors.rightMargin: 18
                                    spacing: 14

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "\uedfb"
                                        font.pixelSize: 18
                                        font.family: "CaskaydiaCove NF"
                                        color: searchInput.activeFocus ? Theme.primaryColor : Theme.onSurfaceVariant
                                    }

                                    TextInput {
                                        id: searchInput
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 60
                                        verticalAlignment: TextInput.AlignVCenter
                                        color: Theme.onSurface
                                        font.pixelSize: 14
                                        font.family: "CaskaydiaCove NF"
                                        clip: true
                                        selectByMouse: true
                                        selectionColor: Theme.primaryContainer
                                        onTextChanged: {
                                            const query = searchInput.text.toLowerCase().trim();
                                            folderModel.nameFilters = query ? [`*${query}*.jpg`, `*${query}*.jpeg`] : ["*.jpg", "*.jpeg"];
                                            if (listView.count > 0) {
                                                listView.highlightMoveDuration = 0;
                                                listView.currentIndex = 0;
                                                listView.positionViewAtIndex(0, ListView.Center);
                                                Qt.callLater(() => {
                                                    listView.highlightMoveDuration = 300;
                                                });
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
                                    }

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 22
                                        height: 22
                                        color: "transparent"
                                        visible: searchInput.text !== ""
                                        Text {
                                            anchors.centerIn: parent
                                            text: "×"
                                            color: Theme.primaryColor
                                            font.pixelSize: 16
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

                            Repeater {
                                model: Theme.schemeTypes

                                ControlButton {
                                    required property string modelData
                                    text: Theme.getSchemeDisplayName(modelData)
                                    isActive: Theme.currentSchemeType === modelData
                                    onClicked: Theme.setSchemeType(modelData)
                                }
                            }
                        }

                        ControlButton {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 44
                            iconText: isRefreshing ? "\uf110" : "\uf021"
                            iconRotating: isRefreshing
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

    FolderListModel {
        id: folderModel
        folder: root.thumbsPath
        nameFilters: ["*.jpg", "*.jpeg"]
        showDirs: false
    }

    function resetFilter() {
        if (contentLoader.item) {
            const searchInput = contentLoader.item.children[0].children[1].children[0].children[0].children[1];
            if (searchInput && searchInput.text !== undefined) {
                searchInput.text = "";
            }
        }
    }

    function positionToCurrentWallpaper() {
        if (!contentLoader.item?.listView || !Dat.WallpaperConfigAdapter.currentWallpaper)
            return;

        const listView = contentLoader.item.listView;
        listView.highlightMoveDuration = 0;

        const currentFilename = Dat.WallpaperConfigAdapter.currentWallpaper.split('/').pop();
        for (let i = 0; i < folderModel.count; i++) {
            if (folderModel.get(i, "fileName") === currentFilename) {
                listView.currentIndex = i;
                listView.positionViewAtIndex(i, ListView.Center);
                break;
            }
        }
    }

    function applyWallpaper(index) {
        const fileName = folderModel.get(index, "fileName");
        const fullPath = picturesPath + fileName;
        const thumbPath = thumbsPath + fileName;

        Theme.thumbPath = thumbPath;
        Theme.saveTheme();

        Quickshell.execDetached(["quickshell", "ipc", "call", "wallpaper", "setWallpaper", fullPath]);
        Quickshell.execDetached(["/usr/bin/sh", "-c", `mkdir -p /home/safal726/.cache/safalQuick/ && cp "${fullPath}" /home/safal726/.cache/safalQuick/bg.jpg`]);

        const wallpaperName = fileName.replace(/\.[^/.]+$/, "").replace(/_/g, " ");
        Quickshell.execDetached(["/usr/bin/notify-send", "--app-name=Wallski", "✓ Wallpaper Applied", wallpaperName]);

        wallpaperChanged(fullPath);
    }

    component ControlButton: Rectangle {
        id: controlBtn
        property alias text: buttonText.text
        property alias iconText: buttonText.text
        property bool isActive: false
        property bool iconRotating: false

        signal clicked

        height: 44
        width: controlBtn.text ? buttonText.implicitWidth + 20 : 44
        radius: (controlBtn.isActive || mouseArea.containsMouse) ? height / 2 : 12
        color: controlBtn.isActive ? Theme.primaryContainer : (mouseArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)
        border.width: 1
        border.color: Theme.outlineVariant

        Behavior on radius {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: buttonText
            anchors.centerIn: parent
            color: controlBtn.isActive ? Theme.onPrimaryContainer : Theme.onSurface
            font.pixelSize: controlBtn.iconText ? 18 : 10
            font.family: "CaskaydiaCove NF"
            font.weight: controlBtn.isActive ? Font.DemiBold : Font.Normal

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            RotationAnimation on rotation {
                running: controlBtn.iconRotating
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: controlBtn.clicked()
        }
    }
}
