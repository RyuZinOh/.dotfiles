import QtQuick
import QtQuick.Layouts
import SddmComponents 2.0 as SDDM

Item {
    id: formContainer

    SDDM.TextConstants {
        id: textConstants
    }

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

        Component.onCompleted: {
            forceActiveFocus();
        }

        onAccepted: {
            sddm.login(userModel.lastUser, text, sessionIndex);
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                text = "";
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
            failed = true;
            passwordInput.text = "";
            resetError.running ? resetError.restart() : resetError.start();
        }
    }
}
