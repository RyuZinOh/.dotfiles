import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell.Io
import qs.Services.Shapes
import qs.Data as Dat

Item {
    id: root
    height: content.height

    property bool isHovered: false
    readonly property string thumbsPath: "file:///home/safal726/thumbs/"
    readonly property string picturesPath: "/home/safal726/Pictures/"

    signal wallpaperChanged(string path)

    onIsHoveredChanged: {
        if (!isHovered) {
            searchInput.text = "";
            searchInput.focus = false;
        }
    }

    PopoutShape {
        id: content
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: root.isHovered ? 369 : 0.1
        style: 1
        alignment: 3
        radius: 20
        color: "black"

        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuad
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 18
            visible: root.isHovered

            // HEADER
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Text {
                    text: "WALLPAPERS"
                    color: "white"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    font.family: "CaskaydiaCove NF"
                }

                Item {
                    Layout.fillWidth: true
                }

                // the counter
                Rectangle {
                    Layout.preferredWidth: countText.width + 20
                    Layout.preferredHeight: 28
                    radius: 10
                    color: "#1E1E1E"
                    border.width: 1
                    border.color: "white"

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: folderModel.count + " images"
                        color: "white"
                        font.pixelSize: 13
                        font.family: "CaskaydiaCove NF"
                    }
                }
            }

            // SEARCH BAR
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 14
                color: "black"
                border.width: searchInput.activeFocus ? 2 : 1
                border.color: searchInput.activeFocus ? "blue" : "white"

                Behavior on border.width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: ""
                        font.pixelSize: 18
                        font.family: "CaskaydiaCove NF"
                        color: searchInput.activeFocus ? "blue" : "black"

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: "white"
                        font.pixelSize: 15
                        font.family: "CaskaydiaCove NF"
                        clip: true
                        selectByMouse: true
                        selectionColor: "black"

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: "find wallpapers..."
                            color: "white"
                            visible: !searchInput.text && !searchInput.activeFocus
                            font.pixelSize: 15
                            font.family: "CaskaydiaCove NF"
                        }

                        onTextChanged: {
                            const query = text.toLowerCase().trim();
                            folderModel.nameFilters = query ? [`*${query}*.jpg`, `*${query}*.jpeg`,] : ["*.jpg", "*.jpeg",];
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: clearMouseArea.containsMouse ? "" : "black"
                        visible: searchInput.text !== ""
                        scale: clearMouseArea.containsMouse ? 1.1 : 1.0

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "x"
                            color: "white"
                            font.pixelSize: 14
                            font.family: "CaskaydiaCove NF"
                        }

                        MouseArea {
                            id: clearMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                searchInput.text = "";
                                searchInput.focus = false;
                            }
                        }
                    }
                }
            }

            // WALLPAPER GRID
            ListView {
                id: wallpaperList
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                spacing: 18
                clip: true
                cacheBuffer: 600

                model: folderModel

                flickDeceleration: 4000
                maximumFlickVelocity: 3000
                //scrollBar
                ScrollBar.horizontal: ScrollBar {
                    id: scrollBar
                    policy: ScrollBar.AlwaysOn
                    visible: wallpaperList.count > 0
                    height: 10

                    contentItem: Rectangle {
                        implicitWidth: 10
                        implicitHeight: 10
                        radius: 5
                        color: "white"
                        opacity: scrollBar.hovered || scrollBar.pressed ? 1.0 : 0.6
                        scale: scrollBar.pressed ? 0.95 : (scrollBar.hovered ? 1.1 : 1.0)

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutQuad
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    background: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 10
                        radius: 5
                        color: "transparent"
                        opacity: 0.4

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                }

                delegate: WallpaperThumbnail {
                    required property string fileName

                    width: 260
                    height: 160
                    thumbSource: root.thumbsPath + fileName
                    name: fileName
                    isCurrentWallpaper: {
                        const currentWall = Dat.WallpaperConfig.currentWallpaper;
                        return currentWall.includes(fileName);
                    }

                    onClicked: {
                        const fullPath = root.picturesPath + fileName;
                        const fileUrl = "file://" + fullPath;

                        Dat.WallpaperConfig.currentWallpaper = fileUrl;
                        Dat.WallpaperConfig.saveWallpaper(fileUrl);
                        copyProcess.command = ["/usr/bin/sh", "-c", `mkdir -p /home/safal726/.cache/hyprlock-safal && cp "${fullPath}" /home/safal726/.cache/hyprlock-safal/bg.jpg`];
                        copyProcess.running = true;
                        const wallpaperName = fileName.replace(/\.[^/.]+$/, "");
                        notifyProcess.command = ["/usr/bin/notify-send", "✓ Wallpaper Applied", wallpaperName];
                        notifyProcess.running = true;

                        root.wallpaperChanged(fullPath);
                    }
                }

                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    visible: wallpaperList.count === 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: searchInput.text ? `No results for "${searchInput.text}"` : "No wallpapers found"
                        color: "white"
                        font.pixelSize: 15
                        font.family: "CaskaydiaCove NF"
                        font.weight: Font.Medium
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: searchInput.text ? "Try a different search term" : "Add images to ~/Pictures/"
                        color: "gray"
                        font.pixelSize: 13
                        font.family: "CaskaydiaCove NF"
                        visible: true
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: root.isHovered = hovered
    }

    FolderListModel {
        id: folderModel
        folder: root.thumbsPath
        nameFilters: ["*.jpg", "*.jpeg"]
        showDirs: false
    }

    Process {
        id: notifyProcess
    }

    Process {
        id: copyProcess
    }

    // Enhanced thumbnail component
    component WallpaperThumbnail: Item {
        id: thumb

        property string thumbSource
        property string name
        property bool isCurrentWallpaper: false
        signal clicked

        Rectangle {
            id: card
            anchors.fill: parent
            color: "transparent"
            radius: 12
            scale: mouseArea.pressed ? 1 : (mouseArea.containsMouse ? 1.08 : 1.0)
            // border.width: thumb.isCurrentWallpaper ? 3 : (mouseArea.containsMouse ? 2 : 0)
            // border.color: thumb.isCurrentWallpaper ? "blue" : "white"

            Behavior on scale {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 200
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                }
            }

            // Current wallpaper badge
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 10
                anchors.rightMargin: 10
                width: badgeText.width + 16
                height: 26
                radius: 13
                color: "blue"
                visible: thumb.isCurrentWallpaper
                z: 10

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: " Active"
                    color: "white"
                    font.pixelSize: 11
                    font.family: "CaskaydiaCove NF"
                    font.weight: Font.Bold
                }
            }

            Image {
                id: img
                anchors.fill: parent
                anchors.margins: 4
                source: thumb.thumbSource
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                cache: true
            }

            // Hover overlay
            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                color: "black"
                opacity: mouseArea.containsMouse ? 0.5 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    opacity: mouseArea.containsMouse ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: ""
                        color: "white"
                        font.pixelSize: 32
                        font.family: "CaskaydiaCove NF"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        // remove thumbs extenstion
                        text: thumb.name.replace(/\.[^/.]+$/, "")
                        color: "white"
                        font.pixelSize: 13
                        font.family: "CaskaydiaCove NF"
                        font.weight: Font.Medium
                        elide: Text.ElideMiddle
                        width: card.width - 40
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: {
                    thumb.clicked();
                }
            }
        }
    }
}
