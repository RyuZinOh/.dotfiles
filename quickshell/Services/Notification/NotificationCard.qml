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

    signal dismissed
    signal actionInvoked(actionId: string)

    width: parent.width
    height: contentColumn.height + 40
    color: NotificationColors.tertiary

    //resolve icon from desktop entry or icon name
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

    Component.onCompleted: {
        showAnimation.start();
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
            script: card.dismissed()
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton


        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton) {
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

        //header
        Row {
            width: parent.width
            spacing: 12

            //icon thingy
            Rectangle {
                id: iconContainer
                width: 40 
                height: 40
                radius: 6
                color: NotificationColors.primary
                visible: appIcon !== "" || appName !== ""

                Image {
                    id: appIconImage
                    anchors.fill: parent
                    anchors.margins: 4
                    source: getIconSource()
                    fillMode: Image.PreserveAspectFit
                    visible: source !== "" && status === Image.Ready
                    asynchronous: true
                    cache: false

                    onStatusChanged: {
                        if (status === Image.Error) {
                            console.log("Failed to load icon from:", source);
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: appName !== "" && (!appIconImage.visible || appIconImage.status !== Image.Ready)
                    text: appName.charAt(0).toUpperCase()
                    font.family: "Poppins"
                    font.pixelSize: 40
                    font.weight: Font.Bold
                    color: NotificationColors.tertiary
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

            Item {
                width: parent.width - iconContainer.width - appNameText.width - closeButton.width - 36
                height: 1
            }

            //close button
            Rectangle {
                id: closeButton
                width: 20
                height: 20
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 16
                    color: NotificationColors.primary
                text: ""
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: hideAnimation.start()
                    cursorShape: Qt.PointingHandCursor
                }
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
        Text {
            text: body
            font.family: "Poppins"
            font.pixelSize: 12
            color: NotificationColors.secondary
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
            width: parent.width
            visible: body !== ""
        }
    }
}
