import QtQuick

Item {
    id: root
    property real fill: 1.0
    property color fillColor: "white"
    property color bgColor: "white"
    property color textColor: "black"
    property int bWidth: 40
    property int bHeight: 20
    signal entered
    signal exited
    signal clicked

    implicitWidth: bWidth + 3
    implicitHeight: bHeight

    Behavior on fill {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Row {
        spacing: 0
        Rectangle {
            width: root.bWidth
            height: root.bHeight
            radius: 5
            color: root.bgColor
            border.color: root.fillColor
            border.width: 3
            Item {
                clip: true
                width: (parent.width - 4) * Math.max(0, Math.min(1, root.fill))
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: root.bWidth - 4
                    height: root.bHeight - 4
                    radius: 3
                    color: root.fillColor
                }
            }
        }

        Rectangle {
            width: 3
            height: root.bHeight * 0.4
            anchors.verticalCenter: parent.verticalCenter
            radius: 1
            color: root.fillColor
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        hoverEnabled: true
        onEntered: root.entered()
        onClicked: root.clicked()
        onExited: root.exited()
    }
}
