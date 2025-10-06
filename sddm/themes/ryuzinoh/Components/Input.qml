import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Column {
    id: inputContainer
    Layout.fillWidth: true
    spacing: 12
    property bool failed

    Item {
        width: parent.width / 2
        height: 28
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            id: errorMessage
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 12
            font.italic: true
            color: "#ff0000"
            opacity: 0
            text: failed ? "Login failed!" : keyboard.capsLock ? "Caps Lock is on" : null

            states: [
                State { name: "fail"; when: failed; PropertyChanges { target: errorMessage; opacity: 1 } },
                State { name: "capslock"; when: keyboard.capsLock; PropertyChanges { target: errorMessage; opacity: 1 } }
            ]

            transitions: Transition { PropertyAnimation { properties: "opacity"; duration: 100 } }
        }
    }

    Row {
        id: passwordRow
        width: parent.width * 0.7
        height: 48
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Item {
            width: parent.width
            height: parent.height

            Button {
                id: passwordIcon
                width: parent.height
                height: parent.height
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                z: 2

                icon.source: password.echoMode === TextInput.Normal ? "../Assets/Password.svg" : "../Assets/Password2.svg"
                icon.color: "#000000"
                icon.width: parent.height * 0.45
                icon.height: parent.height * 0.45

                background: Rectangle { color: "transparent"; border.color: "transparent" }

                onClicked: password.echoMode = password.echoMode === TextInput.Normal ? TextInput.Password : TextInput.Normal
            }

            TextField {
                id: password
                height: parent.height
                width: parent.width
                anchors.centerIn: parent
                horizontalAlignment: TextInput.AlignLeft
                font.bold: true
                color: "#000000"
                echoMode: TextInput.Password
                placeholderText: "Enter Password"
                placeholderTextColor: "#666666"
                passwordCharacter: "•"
                passwordMaskDelay: 1000
                selectByMouse: true
                leftPadding: passwordIcon.width + 12

                background: Rectangle {
                    color: "#ffffff"
                    border.color: password.activeFocus ? "#000000" : "#cccccc"
                    border.width: password.activeFocus ? 2 : 1
                    radius: height / 2
                }

                onAccepted: loginArrow.clicked()
            }
        }

        Button {
            id: loginArrow
            visible: false
            enabled: true

            onClicked: sddm.login(userModel.lastUser, password.text, sessionSelect.sessionIndex)
            Keys.onReturnPressed: clicked()
            Keys.onEnterPressed: clicked()

            background: Rectangle {
                color: "#000000"
                radius: height / 2
            }
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: failed = false
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            failed = true
            resetError.running ? resetError.restart() : resetError.start()
        }
    }
}
