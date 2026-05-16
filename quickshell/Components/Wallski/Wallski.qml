pragma ComponentBehavior: Bound
import Qt.labs.folderlistmodel
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Services.Shapes
import qs.Services.Theme
import qs.utils
import qs.Services.Paths

Item {
    id: root

    property bool isHovered: false
    property bool isRefreshing: false
    property bool contentVisible: false
    readonly property string thumbsPath: PathService.home + "/thumbs/"
    readonly property string picturesPath: PathService.home + "/Pictures/"
    readonly property string thumbsUrl: "file://" + PathService.home + "/thumbs/"

    signal wallpaperChanged(string path)

    function positionToCurrentWallpaper() {
        if (!WallpaperConfig.currentWallpaper)
            return;
        const cur = WallpaperConfig.currentWallpaper.split('/').pop();
        for (let i = 0; i < filteredModel.count; i++) {
            if (filteredModel.get(i).fileName === cur) {
                listView.currentIndex = i;
                listView.positionViewAtIndex(i, ListView.Center);
                return;
            }
        }
    }

    function applyWallpaper(index) {
        const fn = filteredModel.get(index).fileName;
        const fp = root.picturesPath + fn;
        Theme.thumbPath = root.thumbsPath + fn;
        Theme.saveTheme();
        Theme.generateColors();
        WallpaperConfig.currentWallpaper = fp;
        WallpaperConfig.saveConfig();
        Quickshell.execDetached(["/usr/bin/sh", "-c", `mkdir -p ${PathService.home}/.cache/safalQuick/ && cp "${fp}" ${PathService.home}/.cache/safalQuick/bg.jpg`]);
        Quickshell.execDetached(["/usr/bin/notify-send", "--app-name=Wallski", "✓ Wallpaper Applied", fn.replace(/\.[^/.]+$/, "").replace(/_/g, " ")]);
        root.wallpaperChanged(fp);
        PaimonClockConfig.randomizePosition();
    }
    function applyFilter(query) {
        filteredModel.clear();
        const q = query.toLowerCase().trim();
        for (let i = 0; i < folderModel.count; i++) {
            const fn = folderModel.get(i, "fileName");
            if (!q || fn.toLowerCase().includes(q))
                filteredModel.append({
                    fileName: fn
                });
        }
        if (!q)
            Qt.callLater(root.positionToCurrentWallpaper);
        else {
            listView.currentIndex = 0;
            listView.positionViewAtIndex(0, ListView.Center);
        }
    }

    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: content.width
    height: content.height
    FolderListModel {
        id: folderModel
        folder: root.thumbsUrl
        nameFilters: ["*.jpg", "*.jpeg"]
        showDirs: false
        onCountChanged: if (root.contentVisible)
            root.applyFilter("")
    }

    ListModel {
        id: filteredModel
    }

    HoverHandler {
        onHoveredChanged: {
            root.isHovered = hovered;
            if (hovered) {
                unloadTimer.stop();
                root.contentVisible = true;
                root.applyFilter("");
            } else {
                unloadTimer.restart();
            }
        }
    }

    Timer {
        id: unloadTimer
        interval: 400
        onTriggered: {
            root.contentVisible = false;
            searchInput.text = "";
            searchInput.focus = false;
        }
    }

    Process {
        id: bamProcess
        command: ["/bin/bash", PathService.home + "/.config/quickshell/ryu-shell/Scripts/bam.sh"]
        running: false
        onExited: {
            root.isRefreshing = false;
            filteredModel.clear();
            folderModel.folder = "";
            folderModel.folder = root.thumbsUrl;
        }
    }

    PopoutShape {
        id: content
        width: 1600
        height: root.isHovered ? 330 : 0.1
        alignment: 1
        radius: 15
        color: Theme.surfaceContainerLow
        clip: true

        Column {
            anchors {
                fill: parent
                margins: 8
            }
            spacing: 10
            visible: root.contentVisible

            ClippingRectangle {
                width: parent.width
                height: 260
                radius: 14
                color: Theme.surfaceContainerLow

                ListView {
                    id: listView
                    anchors.fill: parent
                    model: root.contentVisible ? filteredModel : null
                    orientation: ListView.Horizontal
                    spacing: 10
                    highlightMoveDuration: 300
                    preferredHighlightBegin: width / 2 - 160
                    preferredHighlightEnd: width / 2 + 160
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    clip: true
                    interactive: false

                    Rectangle {
                        anchors.centerIn: parent
                        width: 320
                        height: 260
                        color: "transparent"
                        radius: 14
                        border {
                            width: 3
                            color: Theme.primaryColor
                        }
                        z: 100
                    }

                    delegate: Item {
                        id: del
                        required property string fileName
                        required property int index
                        readonly property bool isCurrent: index === ListView.view.currentIndex
                        width: 320
                        height: 260

                        ClippingRectangle {
                            anchors.fill: parent
                            radius: 14
                            color: Theme.surfaceContainerHighest

                            Image {
                                anchors.fill: parent
                                source: root.thumbsUrl + del.fileName
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                asynchronous: true
                                cache: false
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "black"
                                opacity: del.isCurrent ? 0.7 : 0

                                Text {
                                    anchors.centerIn: parent
                                    text: del.fileName.replace(/\.[^/.]+$/, "").replace(/_/g, " ")
                                    color: "white"
                                    elide: Text.ElideMiddle
                                    width: parent.width - 48
                                    horizontalAlignment: Text.AlignHCenter
                                    font {
                                        pixelSize: 13
                                        family: "CaskaydiaCove NF"
                                        weight: Font.Medium
                                    }
                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: del.isCurrent ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: del.isCurrent
                            onClicked: root.applyWallpaper(del.index)
                        }
                    }
                }

                MouseArea {
                    property real acc: 0
                    anchors.fill: parent
                    z: -1
                    acceptedButtons: Qt.NoButton
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
                    visible: filteredModel.count === 0

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
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10

                    Rectangle {
                        id: searchBox
                        property bool expanded: searchHover.containsMouse || searchInput.activeFocus || searchInput.text !== ""
                        height: 44
                        radius: 12
                        color: Theme.surfaceContainerHigh
                        border {
                            width: 1
                            color: searchInput.activeFocus ? Theme.primaryColor : Theme.outlineVariant
                        }
                        clip: true
                        width: expanded ? 320 : 44

                        MouseArea {
                            id: searchHover
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                            z: -1
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 13
                                rightMargin: 13
                            }
                            spacing: 10

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "\uedfb"
                                color: searchInput.activeFocus ? Theme.primaryColor : Theme.onSurfaceVariant
                                font {
                                    pixelSize: 18
                                    family: "CaskaydiaCove NF"
                                }
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }
                            }

                            TextInput {
                                id: searchInput
                                anchors.verticalCenter: parent.verticalCenter
                                width: searchBox.expanded ? searchBox.width - 60 : 0
                                verticalAlignment: TextInput.AlignVCenter
                                color: Theme.onSurface
                                clip: true
                                selectByMouse: true
                                selectionColor: Theme.primaryContainer
                                opacity: searchBox.expanded ? 1 : 0
                                font {
                                    pixelSize: 14
                                    family: "CaskaydiaCove NF"
                                }

                                Keys.onReturnPressed: {
                                    root.applyFilter(text);
                                    text = "";
                                }

                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Search — press Enter"
                                    color: Theme.onSurfaceVariant
                                    visible: !searchInput.text && !searchInput.activeFocus
                                    font {
                                        pixelSize: 13
                                        family: "CaskaydiaCove NF"
                                    }
                                }
                            }
                        }

                        Behavior on width {
                            SpringAnimation {
                                spring: 4.5
                                damping: 0.6
                                epsilon: 0.5
                            }
                        }
                    }

                    Row {
                        id: schemeRow
                        property int hoveredIndex: -1
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter

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
                                color: active ? Theme.primaryContainer : isHov ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

                                topLeftRadius: index === 0 ? 22 : 6
                                bottomLeftRadius: index === 0 ? 22 : 6
                                topRightRadius: index === Theme.schemeTypes.length - 1 ? 22 : 6
                                bottomRightRadius: index === Theme.schemeTypes.length - 1 ? 22 : 6

                                border {
                                    width: 1
                                    color: active ? Theme.primaryColor : Theme.outlineVariant
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
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: schemeRow.hoveredIndex = sb.index
                                    onExited: schemeRow.hoveredIndex = -1
                                    onClicked: Theme.setSchemeType(sb.modelData)
                                }

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 220
                                        easing.type: Easing.OutCubic
                                    }
                                }
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
                            }
                        }
                    }
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    width: 44
                    height: 44
                    radius: refreshMouse.containsMouse ? 22 : 12
                    color: refreshMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                    border {
                        width: 1
                        color: Theme.outlineVariant
                    }
                    enabled: !root.isRefreshing

                    Text {
                        anchors.centerIn: parent
                        text: "\udb84\udf7f"
                        color: Theme.onSurface
                        font {
                            pixelSize: 24
                            family: "CaskaydiaCove NF"
                        }
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
                }
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }
    }
}
