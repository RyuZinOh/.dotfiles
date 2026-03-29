pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.Services.Theme
import qs.Services.Shapes
import qs.utils

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
            root.isHovered = hovered;
            if (hovered) {
                unloadTimer.stop();
                contentWrapper.visible = true;
            } else {
                unloadTimer.restart();
            }
        }
    }

    Timer {
        id: unloadTimer
        interval: 400
        onTriggered: {
            contentWrapper.visible = false;
            searchInput.text = "";
            searchInput.focus = false;
            folderModel.nameFilters = ["*.jpg", "*.jpeg"];
        }
    }

    Process {
        id: bamProcess
        command: ["/bin/bash", "/home/safal726/.dotfiles/quickshell/Scripts/bam.sh"]
        running: false
        onExited: {
            root.isRefreshing = false;
            folderModel.folder = "";
            folderModel.folder = root.thumbsPath;
        }
    }

    FolderListModel {
        id: folderModel
        folder: root.thumbsPath
        nameFilters: ["*.jpg", "*.jpeg"]
        showDirs: false
    }

    PopoutShape {
        id: content
        width: 1600
        height: root.isHovered ? 364 : 0.1
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

        Item {
            id: contentWrapper
            anchors.fill: parent
            anchors.margins: 12
            visible: false
            onVisibleChanged: visible ? Qt.callLater(root.positionToCurrentWallpaper) : (searchInput.focus = false)

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
                        highlightMoveDuration: 300
                        preferredHighlightBegin: width / 2 - 160
                        preferredHighlightEnd: width / 2 + 160
                        highlightRangeMode: ListView.StrictlyEnforceRange
                        clip: true
                        cacheBuffer: 960
                        interactive: false

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
                            id: del
                            required property string fileName
                            required property int index
                            width: 320
                            height: 260
                            readonly property bool isCurrent: index === ListView.view.currentIndex

                            ClippingRectangle {
                                anchors.fill: parent
                                radius: 14

                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.surfaceContainerHighest

                                    Image {
                                        anchors.fill: parent
                                        source: root.thumbsPath + del.fileName
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        asynchronous: true
                                        cache: false
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: "black"
                                    opacity: del.isCurrent ? 0.7 : 0
                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 200
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: del.fileName.replace(/\.[^/.]+$/, "").replace(/_/g, " ")
                                        color: "white"
                                        font {
                                            pixelSize: 13
                                            family: "CaskaydiaCove NF"
                                            weight: Font.Medium
                                        }
                                        elide: Text.ElideMiddle
                                        width: parent.width - 48
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: del.isCurrent ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: del.isCurrent
                                onClicked: root.applyWallpaper(del.index)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        acceptedButtons: Qt.NoButton
                        property real acc: 0
                        onWheel: wheel => {
                            if (wheel.pixelDelta.x === 0)
                                return;
                            acc -= wheel.pixelDelta.x;
                            if (Math.abs(acc) >= 50) {
                                acc > 0 ? listView.incrementCurrentIndex() : listView.decrementCurrentIndex();
                                acc = 0;
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
                            font {
                                pixelSize: 15
                                family: "CaskaydiaCove NF"
                                weight: Font.Medium
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: searchInput.text ? "Try a different search term" : "Add images to ~/Pictures/"
                            color: Theme.onSurfaceVariant
                            font {
                                pixelSize: 13
                                family: "CaskaydiaCove NF"
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 44

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Rectangle {
                            id: searchBox
                            height: 44
                            radius: 12
                            color: Theme.surfaceContainerHigh
                            border.width: 1
                            border.color: searchInput.activeFocus ? Theme.primaryColor : Theme.outlineVariant
                            clip: true
                            property bool expanded: searchHover.containsMouse || searchInput.activeFocus || searchInput.text !== ""

                            states: State {
                                when: searchBox.expanded
                                PropertyChanges {
                                    target: searchBox
                                    width: 320
                                }
                            }
                            width: 44
                            Behavior on width {
                                SpringAnimation {
                                    spring: 4.5
                                    damping: 0.6
                                    epsilon: 0.5
                                }
                            }
                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }

                            MouseArea {
                                id: searchHover
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                                z: -1
                            }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 13
                                anchors.rightMargin: 13
                                spacing: 10

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "\uedfb"
                                    font {
                                        pixelSize: 18
                                        family: "CaskaydiaCove NF"
                                    }
                                    color: searchInput.activeFocus ? Theme.primaryColor : Theme.onSurfaceVariant
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                }

                                TextInput {
                                    id: searchInput
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: searchBox.expanded ? (searchBox.width - 60 - (text !== "" ? 32 : 0)) : 0
                                    verticalAlignment: TextInput.AlignVCenter
                                    color: Theme.onSurface
                                    font {
                                        pixelSize: 14
                                        family: "CaskaydiaCove NF"
                                    }
                                    clip: true
                                    selectByMouse: true
                                    selectionColor: Theme.primaryContainer
                                    opacity: searchBox.expanded ? 1 : 0
                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 180
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    onTextChanged: {
                                        const q = text.toLowerCase().trim();
                                        folderModel.nameFilters = q ? [`*${q}*.jpg`, `*${q}*.jpeg`, `*${q.charAt(0).toUpperCase() + q.slice(1)}*.jpg`, `*${q.charAt(0).toUpperCase() + q.slice(1)}*.jpeg`, `*${q.toUpperCase()}*.jpg`, `*${q.toUpperCase()}*.jpeg`] : ["*.jpg", "*.jpeg"];
                                        if (listView.count > 0) {
                                            listView.currentIndex = 0;
                                            listView.positionViewAtIndex(0, ListView.Center);
                                        }
                                    }

                                    Text {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        text: `Search among ${folderModel.count} wallpapers`
                                        color: Theme.onSurfaceVariant
                                        visible: !searchInput.text && !searchInput.activeFocus
                                        font {
                                            pixelSize: 13
                                            family: "CaskaydiaCove NF"
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 22
                                    height: 22
                                    color: "transparent"
                                    visible: searchInput.text !== "" && searchBox.expanded

                                    Text {
                                        anchors.centerIn: parent
                                        text: "×"
                                        color: Theme.primaryColor
                                        font {
                                            pixelSize: 16
                                            family: "CaskaydiaCove NF"
                                        }
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
                            height: 44
                            width: schemeRow.width
                            anchors.verticalCenter: parent.verticalCenter
                            Row {
                                id: schemeRow
                                spacing: 4
                                property int hoveredIndex: -1
                                Repeater {
                                    model: Theme.schemeTypes
                                    delegate: Rectangle {
                                        id: sb
                                        required property string modelData
                                        required property int index
                                        readonly property bool active: Theme.currentSchemeType === modelData
                                        readonly property bool isHov: schemeRow.hoveredIndex === index
                                        readonly property bool isNeighbor: Math.abs(schemeRow.hoveredIndex - index) === 1
                                        readonly property real bw: sbTxt.implicitWidth + 20
                                        height: 44
                                        width: isHov ? bw + 14 : isNeighbor ? bw - 7 : bw
                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 220
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                        topLeftRadius: index === 0 ? 22 : 6
                                        bottomLeftRadius: index === 0 ? 22 : 6
                                        topRightRadius: index === Theme.schemeTypes.length - 1 ? 22 : 6
                                        bottomRightRadius: index === Theme.schemeTypes.length - 1 ? 22 : 6
                                        color: active ? Theme.primaryContainer : isHov ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                                        border.width: 1
                                        border.color: active ? Theme.primaryColor : Theme.outlineVariant
                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 200
                                            }
                                        }
                                        Behavior on border.color {
                                            ColorAnimation {
                                                duration: 200
                                            }
                                        }
                                        Text {
                                            id: sbTxt
                                            anchors.centerIn: parent
                                            text: Theme.getSchemeDisplayName(sb.modelData)
                                            color: sb.active ? Theme.onPrimaryContainer : Theme.onSurface
                                            font {
                                                pixelSize: 12
                                                family: "CaskaydiaCove NF"
                                                weight: sb.active ? Font.Medium : Font.Normal
                                            }
                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 200
                                                }
                                            }
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onEntered: schemeRow.hoveredIndex = sb.index
                                            onExited: schemeRow.hoveredIndex = -1
                                            onClicked: Theme.setSchemeType(sb.modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: refreshBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 44
                        height: 44
                        radius: refreshMouse.containsMouse ? 22 : 12
                        color: refreshMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                        border.width: 1
                        border.color: Theme.outlineVariant
                        enabled: !root.isRefreshing
                        Behavior on radius {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "\udb84\udf7f"
                            font {
                                pixelSize: 24
                                family: "CaskaydiaCove NF"
                            }
                            color: Theme.onSurface
                            NumberAnimation on rotation {
                                running: root.isRefreshing
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                            }
                        }
                        MouseArea {
                            id: refreshMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.isRefreshing = true;
                                bamProcess.running = true;
                            }
                        }
                    }
                }
            }
        }
    }

    function positionToCurrentWallpaper() {
        if (!WallpaperConfig.currentWallpaper)
            return;
        const cur = WallpaperConfig.currentWallpaper.split('/').pop();
        for (let i = 0; i < folderModel.count; i++) {
            if (folderModel.get(i, "fileName") === cur) {
                listView.currentIndex = i;
                listView.positionViewAtIndex(i, ListView.Center);
                break;
            }
        }
    }

    function applyWallpaper(index) {
        const fn = folderModel.get(index, "fileName");
        const fp = root.picturesPath + fn;
        Theme.thumbPath = root.thumbsPath + fn;
        Theme.saveTheme();
        Quickshell.execDetached(["quickshell", "ipc", "call", "wallpaper", "setWallpaper", fp]);
        Quickshell.execDetached(["/usr/bin/sh", "-c", `mkdir -p /home/safal726/.cache/safalQuick/ && cp "${fp}" /home/safal726/.cache/safalQuick/bg.jpg`]);
        Quickshell.execDetached(["/usr/bin/notify-send", "--app-name=Wallski", "✓ Wallpaper Applied", fn.replace(/\.[^/.]+$/, "").replace(/_/g, " ")]);
        root.wallpaperChanged(fp);
    }
}
