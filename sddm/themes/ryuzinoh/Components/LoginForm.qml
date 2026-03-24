import QtQuick

Item {
    id: formContainer

    property int passwordLength: passwordInput.text.length
    property bool failed: false
    property int sessionIndex: 0

    width: 0
    height: 0
    visible: false

    function focusPassword() {
        passwordInput.forceActiveFocus();
    }

    TextInput {
        id: passwordInput
        visible: false
        enabled: true
        focus: true
        echoMode: TextInput.Password
        Component.onCompleted: forceActiveFocus()
        onAccepted: sddm.login(userModel.lastUser, text, formContainer.sessionIndex)
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                text = "";
            }
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: formContainer.failed = false
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            formContainer.failed = true;
            passwordInput.text = "";
            resetError.running ? resetError.restart() : resetError.start();
        }
    }
}
