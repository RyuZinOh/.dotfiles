pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls

Item {
    id: sessionButton

    required property var model
    required property int currentIndex
    required property font parentFont

    property alias currentText: selectSession.currentText
    property alias hovered: selectSession.hovered
    property alias pressed: selectSession.down

    height: sessionButton.parentFont.pointSize * 2.5
    width: pill.implicitWidth + 32

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: height / 2
        color: "transparent"
        border.color: "#ffffff"
        border.width: 1
        implicitWidth: pillRow.implicitWidth + 32

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: selectSession.currentText !== "" ? selectSession.currentText : "Session"
                color: "#ffffff"
                font.pointSize: sessionButton.parentFont.pointSize * 0.8
                font.family: sessionButton.parentFont.family
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: popupHandler.visible ? "▴" : "▾"
                color: "#888888"
                font.pointSize: sessionButton.parentFont.pointSize * 0.6
            }
        }

        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: popupHandler.visible ? popupHandler.close() : popupHandler.open()
        }
    }

    ComboBox {
        id: selectSession
        visible: false
        model: sessionButton.model
        currentIndex: sessionButton.currentIndex
        textRole: "name"
    }

    Popup {
        id: popupHandler

        parent: sessionButton
        width: Math.max(sessionButton.width, 180)
        x: (sessionButton.width - popupHandler.width) / 2
        y: -popupHandler.height - 8
        padding: 8

        background: Rectangle {
            radius: 12
            color: "transparent"
            border.color: "#ffffff"
            border.width: 1
        }

        contentItem: Column {
            spacing: 2
            clip: true

            Text {
                text: "SESSION"
                color: "#ffffff"
                font.pointSize: sessionButton.parentFont.pointSize * 0.6
                font.family: sessionButton.parentFont.family
                font.letterSpacing: 2
                leftPadding: 8
                topPadding: 4
                bottomPadding: 4
            }

            Repeater {
                model: selectSession.model
                delegate: Rectangle {
                    id: sessionItem
                    required property string name
                    required property int index

                    width: popupHandler.width - 16
                    height: sessionButton.parentFont.pointSize * 2.8
                    radius: 8
                    clip: true
                    color: itemMouse.containsMouse ? "#33ffffff" : selectSession.currentIndex === sessionItem.index ? "#1affffff" : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        text: sessionItem.name
                        color: selectSession.currentIndex === sessionItem.index ? "#ffffff" : "#aaaaaa"
                        font.pointSize: sessionButton.parentFont.pointSize * 0.85
                        font.family: sessionButton.parentFont.family
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        clip: true

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            selectSession.currentIndex = sessionItem.index;
                            popupHandler.close();
                        }
                    }
                }
            }
        }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    property: "y"
                    from: -popupHandler.height + 10
                    to: -popupHandler.height - 8
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }

        exit: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 150
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    property: "y"
                    from: -popupHandler.height - 8
                    to: -popupHandler.height + 6
                    duration: 150
                    easing.type: Easing.InCubic
                }
            }
        }
    }
}
