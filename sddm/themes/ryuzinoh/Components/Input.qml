import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Column {
    id: inputContainer
    Layout.fillWidth: true
    property bool failed

    Item {
        id: errorMessageField
        height: root.font.pointSize * 2
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            id: errorMessage
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: failed ? config.TranslateLoginFailedWarning || textConstants.loginFailed + "!" : keyboard.capsLock ? config.TranslateCapslockWarning || textConstants.capslockWarning : null
            font.pointSize: root.font.pointSize * 0.8
            font.italic: true
            color: config.WarningColor
            opacity: 0
            
            states: [
                State {
                    name: "fail"
                    when: failed
                    PropertyChanges { target: errorMessage; opacity: 1 }
                },
                State {
                    name: "capslock"
                    when: keyboard.capsLock
                    PropertyChanges { target: errorMessage; opacity: 1 }
                }
            ]
            
            transitions: Transition {
                PropertyAnimation { properties: "opacity"; duration: 100 }
            }
        }
    }
    
    Row {
        id: passwordRow
        width: parent.width * 0.8
        height: root.font.pointSize * 3.5
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        
        Item {
            width: parent.width - loginArrow.width - parent.spacing
            height: parent.height
            
            Button {
                id: passwordIcon
                width: parent.height
                height: parent.height
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                z: 2
                
                icon.source: password.echoMode === TextInput.Normal ? "../Assets/Password.svg" : "../Assets/Password2.svg"
                icon.color: hovered ? config.HoverPasswordIconColor : config.PasswordIconColor
                icon.width: parent.height * 0.4
                icon.height: parent.height * 0.4

                background: Rectangle {
                    color: "transparent"
                    border.color: "transparent"
                }

                onClicked: password.echoMode = password.echoMode === TextInput.Normal ? TextInput.Password : TextInput.Normal
            }

            TextField {
                id: password
                height: parent.height
                width: parent.width
                anchors.centerIn: parent
                horizontalAlignment: TextInput.AlignLeft
                font.bold: true
                color: config.PasswordFieldTextColor
                focus: config.PasswordFocus == "true"
                echoMode: TextInput.Password
                placeholderText: config.TranslatePlaceholderPassword || textConstants.password
                placeholderTextColor: config.PlaceholderTextColor
                passwordCharacter: "•"
                passwordMaskDelay: config.HideCompletePassword == "true" ? undefined : 1000
                renderType: Text.QtRendering
                selectByMouse: true
                leftPadding: passwordIcon.width + 15
                
                background: Rectangle {
                    color: config.PasswordFieldBackgroundColor
                    opacity: 0.2
                    border.color: password.activeFocus ? config.HighlightBorderColor : "transparent"
                    border.width: password.activeFocus ? 2 : 1
                    radius: config.RoundCorners || 0
                }
                
                onAccepted: sddm.login(userModel.lastUser, password.text, sessionSelect.sessionIndex)
                Keys.onRightPressed: loginArrow.clicked()
            }
        }
        
        Button {
            id: loginArrow
            height: parent.height
            width: height
            anchors.verticalCenter: parent.verticalCenter
            
            enabled: config.AllowEmptyPassword == "true" || password.text != ""
            hoverEnabled: true

            icon.source: "../Assets/right-arrow.svg"
            icon.color: enabled ? config.LoginButtonTextColor : Qt.darker(config.LoginButtonTextColor, 1.5)
            icon.width: parent.height * 0.5
            icon.height: parent.height * 0.5

            background: Rectangle {
                color: config.LoginButtonBackgroundColor
                opacity: parent.enabled ? 1 : 0.2
                radius: config.RoundCorners || 0
            }

            states: [
                State {
                    name: "pressed"
                    when: loginArrow.down
                    PropertyChanges { target: background; color: Qt.darker(config.LoginButtonBackgroundColor, 1.1) }
                    PropertyChanges { target: loginArrow; icon.color: Qt.darker(config.LoginButtonTextColor, 1.1) }
                },
                State {
                    name: "hovered"
                    when: loginArrow.hovered
                    PropertyChanges { target: background; color: Qt.lighter(config.LoginButtonBackgroundColor, 1.15) }
                    PropertyChanges { target: loginArrow; icon.color: Qt.lighter(config.LoginButtonTextColor, 1.15) }
                },
                State {
                    name: "focused"
                    when: loginArrow.activeFocus
                    PropertyChanges { target: background; color: Qt.lighter(config.LoginButtonBackgroundColor, 1.2) }
                    PropertyChanges { target: loginArrow; icon.color: Qt.lighter(config.LoginButtonTextColor, 1.2) }
                }
            ]
            
            transitions: Transition {
                PropertyAnimation { properties: "opacity, color"; duration: 300 }
            }

            onClicked: sddm.login(userModel.lastUser, password.text, sessionSelect.sessionIndex)
            Keys.onReturnPressed: clicked()
            Keys.onEnterPressed: clicked()
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            failed = true
            resetError.running ? resetError.restart() : resetError.start()
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: failed = false
    }
}
