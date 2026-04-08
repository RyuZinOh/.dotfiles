pragma ComponentBehavior: Bound
import Clipsh
import QtQuick
import QtQuick.Controls
import Quickshell.Widgets
import qs.Services.Theme
import qs.utils

Item {
    id: root

    readonly property real currentPanelHeight: panel.height
    readonly property int panelSize: 500
    readonly property int panelMinHeight: 120
    readonly property int itemH: 53
    readonly property int radius: 12
    readonly property color panelBg: Theme.surfaceContainerLow
    readonly property color inputBg: Theme.surfaceContainer
    readonly property color inputBorder: Theme.outlineVariant
    readonly property color itemBg: Theme.surfaceContainerHigh
    readonly property color itemHoverBg: Theme.primaryContainer
    readonly property color itemText: Theme.onSurface
    readonly property color itemHoverText: Theme.onPrimaryContainer
    readonly property color iconColor: Theme.onSurfaceVariant
    readonly property color wipeBg: Theme.surfaceContainer
    readonly property color wipeBgHover: Theme.errorContainer
    readonly property color wipeIcon: Theme.onSurfaceVariant
    readonly property color wipeIconHover: Theme.onErrorContainer
    readonly property color emptyText: Theme.onSurfaceVariant

    function contentHeight() {
        const cnt = clipsh.history.filter((e) => {
            return searchInput.text === "" || clipsh.previewText(e).toLowerCase().includes(searchInput.text.toLowerCase());
        }).length;
        if (cnt === 0)
            return panelMinHeight;

        const h = 62 + cnt * itemH;
        return Math.min(Math.max(h, panelMinHeight), panelSize);
    }

    anchors.fill: parent
    focus: true
    Component.onCompleted: {
        searchBox.width = topRow.width - 46;
        clipsh.fetchHistory();
        searchInput.forceActiveFocus();
        openAnim.start();
    }
    Component.onDestruction: console.log("[Clipsy] destroyed")
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            ClipsyConfig.dismiss();
            event.accepted = true;
        }
    }

    Clipsh {
        id: clipsh

        Component.onCompleted: fetchHistory()
        onError: (msg) => {
            return console.warn("[Clipsy] error:", msg);
        }
        onItemCopied: ClipsyConfig.dismiss()
        onWiped: ClipsyConfig.dismiss()
    }

    ClippingRectangle {
        id: panel

        property real scaleY: 1

        anchors.centerIn: parent 
        onHeightChanged: ClipsyConfig.panelHeight = height 
        Component.onCompleted: ClipsyConfig.panelHeight = root.contentHeight()
        width: root.panelSize
        height: root.contentHeight()
        radius: root.radius
        color: root.panelBg

        SequentialAnimation {
            id: openAnim

            NumberAnimation {
                target: panel
                property: "scaleY"
                from: 0.5
                to: 1
                duration: 680
                easing.type: Easing.OutExpo
            }

        }

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => {
                return mouse.accepted = true;
            }
        }

        Row {
            id: topRow

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 12
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            ClippingRectangle {
                id: searchBox

                width: 0
                height: 38
                radius: root.radius
                color: root.inputBg
                border.color: searchInput.activeFocus ? root.inputBorder : "transparent"
                border.width: 1

                Text {
                    id: searchIcon

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: "\uedfb"
                    font.pixelSize: 15
                    color: root.iconColor
                }

                TextField {
                    id: searchInput

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: searchIcon.right
                    anchors.right: parent.right
                    anchors.leftMargin: 6
                    anchors.rightMargin: 8
                    height: 38
                    placeholderText: "Search…"
                    placeholderTextColor: root.iconColor
                    color: root.itemText
                    font.pixelSize: 13
                    focus: true
                    onTextChanged: listView.forceLayout()
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            ClipsyConfig.dismiss();
                            event.accepted = false;
                        }
                    }

                    background: Item {
                    }

                }

            }

            ClippingRectangle {
                width: 38
                height: 38
                radius: root.radius
                color: wipeMouse.containsMouse ? root.wipeBgHover : root.wipeBg

                Text {
                    anchors.centerIn: parent
                    text: "\udb80\uddb4"
                    font.pixelSize: 16
                    color: wipeMouse.containsMouse ? root.wipeIconHover : root.wipeIcon
                }

                MouseArea {
                    id: wipeMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: clipsh.wipe()
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }

                }

            }

        }

        ClippingRectangle {
            id: listContainer

            anchors.top: topRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            anchors.topMargin: 8
            radius: root.radius
            color: "transparent"

            ListView {
                id: listView

                anchors.fill: parent
                spacing: 5
                clip: true
                model: clipsh.history.filter((e) => {
                    return searchInput.text === "" || clipsh.previewText(e).toLowerCase().includes(searchInput.text.toLowerCase());
                })

                Text {
                    anchors.centerIn: parent
                    visible: listView.count === 0 && !clipsh.loading
                    text: "No clipboard history"
                    color: root.emptyText
                    font.pixelSize: 13
                }

                Text {
                    anchors.centerIn: parent
                    visible: clipsh.loading
                    text: "Loading…"
                    color: root.emptyText
                    font.pixelSize: 13
                }

                add: Transition {
                    NumberAnimation {
                        property: "y"
                        from: ViewTransition.destination.y + 10
                        to: ViewTransition.destination.y
                        duration: 260
                        easing.type: Easing.OutExpo
                    }

                }

                delegate: ClippingRectangle {
                    id: delegateRoot

                    required property var modelData

                    width: listView.width
                    height: clipsh.isImage(modelData) ? 110 : 48
                    radius: root.radius
                    color: itemMouse.containsMouse ? root.itemHoverBg : root.itemBg

                    Image {
                        visible: clipsh.isImage(delegateRoot.modelData)
                        anchors.fill: parent
                        anchors.margins: 6
                        source: clipsh.isImage(delegateRoot.modelData) ? clipsh.tempImagePath(delegateRoot.modelData) : ""
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }

                    Text {
                        visible: !clipsh.isImage(delegateRoot.modelData)
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        text: clipsh.previewText(delegateRoot.modelData)
                        color: itemMouse.containsMouse ? root.itemHoverText : root.itemText
                        font.pixelSize: 12
                        elide: Text.ElideRight

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                                easing.type: Easing.OutQuad
                            }

                        }

                    }

                    MouseArea {
                        id: itemMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clipsh.copyItem(delegateRoot.modelData)
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                            easing.type: Easing.OutQuad
                        }

                    }

                }

            }

        }

        transform: Scale {
            origin.x: panel.width / 2
            origin.y: panel.height / 2
            yScale: panel.scaleY
        }

        Behavior on height {
            NumberAnimation {
                duration: 1100
                easing.type: Easing.OutElastic
                easing.amplitude: 1
                easing.period: 0.55
            }

        }

    }

    Connections {
        function onShowClipsy() {
        }

        function onHideClipsy() {
        }

        target: ClipsyConfig
    }

}
