import QtQuick

Rectangle {
    id: card

    property int notifId: 0
    property string summary: ""
    property string body: ""
    property string appName: ""
    property string appIcon: ""
    property string desktopEntry: ""
    property var actions: []
    
    // timer properties
    property int autoCloseDuration: 5000 // 5 sec
    property bool isHovered: false
    property real progress: 0
    property bool isActiveCard: false // only active card runs timer

    signal dismissed
    signal actionInvoked(actionId: string)

    width: parent ? parent.width : 360 
    height: contentColumn.height + 32
    color:  "#100C08"
    radius: 12

    function getIconSource() {
        if (appIcon !== "" && (appIcon.startsWith("/") || appIcon.startsWith("file://") || appIcon.startsWith("http://") || appIcon.startsWith("https://"))) {
            return appIcon;
        }
        if (desktopEntry !== "") {
            return "file:///usr/share/icons/hicolor/scalable/apps/" + desktopEntry.toLowerCase() + ".svg";
        }
        if (appIcon !== "") {
            return "file:///usr/share/icons/hicolor/scalable/apps/" + appIcon.toLowerCase() + ".svg";
        }
        return "";
    }

    function startTimer() {
        card.progress = 0;
        autoCloseTimer.start();
    }

    function stopTimer() {
        autoCloseTimer.stop();
    }

    onIsActiveCardChanged: {
        if (isActiveCard) {
            startTimer();
        } else {
            stopTimer();
            card.progress = 0;
        }
    }

    Component.onCompleted: {
        showAnimation.start();
    }

    // only run when card is active
    Timer {
        id: autoCloseTimer
        interval: 50
        repeat: true
        running: false
        
        onTriggered: {
            if (!card.isActiveCard) {
                stop();
                return;
            }
            
            if (!card.isHovered) {
                card.progress += 50 / card.autoCloseDuration;
                if (card.progress >= 1.0) {
                    autoCloseTimer.stop();
                    hideAnimation.start();
                }
            }
        }
    }

    ParallelAnimation {
        id: showAnimation
        NumberAnimation {
            target: card
            easing.type: Easing.Linear
        }
    }

    SequentialAnimation {
        id: hideAnimation
        ParallelAnimation {
            NumberAnimation {
                target: card
                property: "x"
                to: 600
                duration: 450
                easing.type: Easing.Linear
            }
        }
        ScriptAction {
            script: {
                NotificationService.dismiss(card.notifId);
                card.dismissed();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: {
            card.isHovered = true;
        }

        onExited: {
            card.isHovered = false;
        }

        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton) {
                autoCloseTimer.stop();
                hideAnimation.start();
            }
        }
    }

    Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        spacing: 12

        // also only visible for active card
        Rectangle {
            width: parent.width
            height: 3
            color: NotificationColors.tertiary
            radius: 1.5
            visible: card.isActiveCard

            Rectangle {
                width: parent.width * card.progress
                height: parent.height
                color: NotificationColors.primary
                radius: 1.5

                Behavior on width {
                    NumberAnimation {
                        duration: 50
                        easing.type: Easing.Linear
                    }
                }
            }
        }

        //header
        Row {
            width: parent.width
            spacing: 12

            //icon thingy
            Rectangle {
                id: iconContainer
                width: 50
                height: 50
                radius: 6
                color: "transparent"
                visible: appIcon !== "" || appName !== ""

                AnimatedImage {
                    id: appIconAnimated
                    anchors.fill: parent

                    source: getIconSource()
                    fillMode: Image.PreserveAspectFit
                    visible: source !== "" && status === Image.Ready && source.toString().toLowerCase().endsWith(".gif")
                    asynchronous: true
                    cache: false
                    playing: true

                    onStatusChanged: {
                        if (status === Image.Error) {
                            console.log("Failed to load animated icon from:", source);
                        }
                    }
                }

                Image {
                    id: appIconImage
                    anchors.fill: parent
                    anchors.margins: 4
                    source: getIconSource()
                    fillMode: Image.PreserveAspectFit
                    visible: source !== "" && status === Image.Ready && !source.toString().toLowerCase().endsWith(".gif")
                    asynchronous: false
                    cache: true

                    onStatusChanged: {
                        if (status === Image.Error) {
                            console.log("Failed to load icon from:", source);
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: appName !== "" && (!appIconImage.visible && !appIconAnimated.visible)
                    text: appName.charAt(0).toUpperCase()
                    font.family: "Poppins"
                    font.pixelSize: 40
                    font.weight: Font.Bold
                    color: NotificationColors.secondary
                }
            }

            //appName
            Text {
                id: appNameText
                text: appName
                font.family: "Poppins"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: NotificationColors.secondary
                opacity: 0.8
                visible: appName !== ""
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        //summary
        Text {
            id: summaryText
            text: summary
            font.family: "Poppins"
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: NotificationColors.secondary
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            width: parent.width
        }
        //body
        Item {
            id: bodyCarouselContainer
            width: parent.width
            height: {
                if (body === "") return 0;
                var baseHeight = expanded ? bodyText.contentHeight : Math.min(bodyText.contentHeight, bodyText.font.pixelSize * 3.5);
                var needsArrows = bodyText.implicitHeight > bodyText.font.pixelSize * 3.5;
                return baseHeight + (needsArrows ? 34 : 0);
            }
            visible: body !== ""

            property bool expanded: false

            Rectangle {
                id: bodyContainer
                width: parent.width
                height: parent.expanded ? bodyText.contentHeight : Math.min(bodyText.contentHeight, bodyText.font.pixelSize * 3.5)
                clip: true
                color: "transparent"

                Behavior on height {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    id: bodyText
                    text: body
                    font.family: "Poppins"
                    font.pixelSize: 12
                    color: NotificationColors.secondary
                    wrapMode: Text.Wrap
                    width: parent.width
                    maximumLineCount: parent.parent.expanded ? -1 : 3
                    elide: parent.parent.expanded ? Text.ElideNone : Text.ElideRight
                }
            }

            // carousal
            Row {
                anchors.top: bodyContainer.bottom
                anchors.topMargin: 6
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8
                visible: bodyText.implicitHeight > bodyText.font.pixelSize * 3.5

                // collapse
                Rectangle {
                    width: 26
                    height: 26
                    radius: 13
                    color: upMouseArea.containsMouse ? NotificationColors.primary : NotificationColors.tertiary
                    visible: parent.parent.expanded

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    Text {
                        anchors.centerIn: parent
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 14
                        color: NotificationColors.secondary
                        text: ""
                    }

                    MouseArea {
                        id: upMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            bodyCarouselContainer.expanded = false;
                        }
                    }
                }

                // expansion
                Rectangle {
                    width: 26
                    height: 26
                    radius: 13
                    color: downMouseArea.containsMouse ? NotificationColors.primary : NotificationColors.tertiary
                    visible: !parent.parent.expanded

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    Text {
                        anchors.centerIn: parent
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 14
                        color: NotificationColors.secondary
                        text: ""
                    }

                    MouseArea {
                        id: downMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            bodyCarouselContainer.expanded = true;
                        }
                    }
                }
            }
        }
    }
}
