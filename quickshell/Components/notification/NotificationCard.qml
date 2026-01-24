pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.utils
import qs.Services.Theme
import qs.Services

Rectangle {
    id: card

    property int notifId: 0
    property string summary: ""
    property string body: ""
    property string appName: ""
    property bool isActive: false
    property real progress: 0
    property bool expanded: false
    readonly property bool isLongText: bodyText.implicitHeight > bodyText.font.pixelSize * 3.5

    width: card.parent ? card.parent.width : 400
    height: content.height + 32
    radius: 16
    color: Theme.surfaceColor
    opacity: 1
    scale: 0.92
    x: 600

    Component.onCompleted: {
        Qt.callLater(() => {
            card.scale = 1;
            card.x = 0;
            card.updateActiveState();
        });
    }

    Behavior on scale {
        NumberAnimation {
            duration: 450
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }
    Behavior on x {
        enabled: !dragArea.pressed
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    function updateActiveState() {
        card.isActive = card.parent && card.parent.children[0] === card;
        if (card.isActive) {
            card.progress = 0;
            autoCloseTimer.restart();
        }
    }

    function dismiss() {
        hideAnim.start();
    }

    Connections {
        target: card.parent
        function onChildrenChanged() {
            card.updateActiveState();
        }
    }

    Timer {
        id: autoCloseTimer
        interval: 50
        repeat: true
        running: false
        onTriggered: {
            if (!card.isActive) {
                autoCloseTimer.stop();
                return;
            }
            if (dragArea.containsMouse || dragArea.pressed || expandArea.containsMouse || collapseArea.containsMouse) {
                return;
            }
            card.progress += 50 / NotificationConfig.autoCloseDuration;

            if (card.progress >= 1) {
                autoCloseTimer.stop();
                card.dismiss();
            }
        }
    }

    SequentialAnimation {
        id: hideAnim
        ParallelAnimation {
            NumberAnimation {
                target: card
                property: "x"
                to: 700
                duration: 350
                easing.type: Easing.InBack
                easing.overshoot: 1.5
            }
            NumberAnimation {
                target: card
                property: "scale"
                to: 0.85
                duration: 350
                easing.type: Easing.InCubic
            }
        }
        ScriptAction {
            script: Qt.callLater(() => {
                NotificationService.dismiss(card.notifId);
                card.destroy();
            })
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: dragArea.containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        drag.target: card
        drag.axis: Drag.XAxis
        drag.minimumX: -700
        drag.maximumX: 700
        propagateComposedEvents: true

        onReleased: mouse => {
            if (Math.abs(card.x) > 100)
                card.dismiss();
            else
                card.x = 0;
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                card.dismiss();
        }
    }

    Column {
        id: content
        anchors {
            left: card.left
            right: card.right
            top: card.top
            margins: 18
        }
        spacing: 14

        Rectangle {
            id: progressBar
            width: content.width
            height: 3
            color: Theme.surfaceContainer
            radius: 1.5
            visible: card.isActive

            Rectangle {
                width: progressBar.width * card.progress
                height: progressBar.height
                color: Theme.primaryColor
                radius: 1.5
                Behavior on width {
                    NumberAnimation {
                        duration: 50
                        easing.type: Easing.Linear
                    }
                }
            }
        }

        Row {
            id: headerRow
            width: content.width
            spacing: 14

            Rectangle {
                id: iconRect
                width: 52
                height: 52
                radius: 12
                color: Theme.primaryColor
                opacity: 0.15
                visible: card.appName

                Text {
                    anchors.centerIn: iconRect
                    text: card.appName ? card.appName.charAt(0).toUpperCase() : ""
                    font {
                        pixelSize: 28
                        weight: Font.Bold
                    }
                    color: Theme.primaryColor
                }
            }

            Column {
                anchors.verticalCenter: headerRow.verticalCenter
                spacing: 2

                Text {
                    text: card.appName
                    font {
                        pixelSize: 12
                        weight: Font.Medium
                    }
                    color: Theme.secondaryColor
                    opacity: 0.9
                    visible: card.appName
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        Text {
            id: summaryText
            text: card.summary
            width: content.width
            font {
                pixelSize: 15
                weight: Font.DemiBold
            }
            color: Theme.onSurface
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        Item {
            id: bodyContainer
            width: content.width
            height: card.expanded ? bodyText.height : (card.isLongText ? bodyText.font.pixelSize * 3 : bodyText.height)
            clip: true
            visible: card.body

            Behavior on height {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                id: bodyText
                text: card.body
                width: bodyContainer.width
                font.pixelSize: 13
                color: Theme.onSurface
                opacity: 0.85
                wrapMode: Text.Wrap
                lineHeight: 1.4
            }
        }

        Rectangle {
            id: expandButton
            width: content.width
            height: 32
            radius: 8
            color: expandArea.containsMouse ? Theme.primaryColor : Theme.surfaceContainer
            opacity: expandArea.containsMouse ? 0.2 : 0.5
            visible: card.isLongText && !card.expanded

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

            Row {
                anchors.centerIn: expandButton
                spacing: 8

                Text {
                    id: expandArrow
                    text: "▼"
                    font.pixelSize: 12
                    color: expandArea.containsMouse ? Theme.primaryColor : Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                Text {
                    id: expandLabel
                    text: "Show more"
                    font {
                        pixelSize: 12
                        weight: Font.Medium
                    }
                    color: expandArea.containsMouse ? Theme.primaryColor : Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
            }

            MouseArea {
                id: expandArea
                anchors.fill: expandButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: card.expanded = true
            }
        }

        Rectangle {
            id: collapseButton
            width: content.width
            height: 32
            radius: 8
            color: collapseArea.containsMouse ? Theme.primaryColor : Theme.surfaceContainer
            opacity: collapseArea.containsMouse ? 0.2 : 0.5
            visible: card.isLongText && card.expanded

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

            Row {
                anchors.centerIn: collapseButton
                spacing: 8

                Text {
                    id: collapseArrow
                    text: "▲"
                    font.pixelSize: 12
                    color: collapseArea.containsMouse ? Theme.primaryColor : Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                Text {
                    id: collapseLabel
                    text: "Show less"
                    font {
                        pixelSize: 12
                        weight: Font.Medium
                    }
                    color: collapseArea.containsMouse ? Theme.primaryColor : Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
            }

            MouseArea {
                id: collapseArea
                anchors.fill: collapseButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: card.expanded = false
            }
        }
    }
}
