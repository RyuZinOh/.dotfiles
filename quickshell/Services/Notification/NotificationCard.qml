import QtQuick

Rectangle {
    id: card

    property int notifId: 0
    property string summary: ""
    property string body: ""
    property string appName: ""
    property var actions: []

    signal dismissed
    signal actionInvoked(actionId: string)

    width: parent.width
    height: contentColumn.height + 40
    color: NotificationColors.tertiary

    Component.onCompleted: {
        showAnimation.start();
        autoHideTimer.start();
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

    Timer {
        id: autoHideTimer
        interval: 2000
        repeat: false
        onTriggered: hideAnimation.start()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: autoHideTimer.stop()
        onExited: autoHideTimer.start()

        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton) {
                hideAnimation.start();
            }
        }
    }

    Column {
        id: contentColumn

        Rectangle {
            id: closeButton
            width: 20
            height: 20
            anchors.right: parent.right
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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 10

        //implementing icon and images
        //soon[someday when i feel like]

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
