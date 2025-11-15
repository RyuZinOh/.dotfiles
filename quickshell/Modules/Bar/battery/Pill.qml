import QtQuick

Item {
    id: root

    // Properties
    property real fill: 1.0
    property color fillColor: "white"
    property color emptyColor: "#1a1a1a"
    property color borderColor: "white"
    property color textColor: "white"
    property int bWidth: 40
    property int bHeight: 20
    property int borderWidth: 2
    property int terminalWidth: 3
    property int terminalHeight: 8

    // Signals
    signal entered
    signal exited
    signal clicked

    implicitWidth: bWidth + terminalWidth
    implicitHeight: bHeight

    // Smooth fill animation
    Behavior on fill {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Row {
        spacing: 0

        // Main battery body
        Rectangle {
            id: batteryBody
            width: root.bWidth
            height: root.bHeight
            radius: 4
            color: root.emptyColor
            border.color: root.borderColor
            border.width: root.borderWidth

            // Fill indicator
            Rectangle {
                id: fillRect
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    margins: root.borderWidth + 1
                }
                width: Math.max(0, (parent.width - (root.borderWidth + 1) * 2) * Math.min(1, root.fill))
                radius: 2
                color: root.fillColor

                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        // Battery terminal
        Rectangle {
            width: root.terminalWidth
            height: root.terminalHeight
            anchors.verticalCenter: parent.verticalCenter
            radius: 1.5
            color: root.borderColor
        }
    }

    // Interactive area
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
