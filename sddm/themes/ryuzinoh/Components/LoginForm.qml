import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0 as SDDM

ColumnLayout {
    id: formContainer
    SDDM.TextConstants { id: textConstants }

    property int p: config.ScreenPadding || 0
    property string a: config.FormPosition || "center"

    spacing: 15  

    Layout.alignment: Qt.AlignCenter

    SessionButton {
        id: sessionSelect
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: Math.min(root.height / 20, 30)  
        Layout.preferredWidth: Math.min(parent.width * 0.7, 300)  
    }


    Input {
        id: input
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: Math.min(root.height / 12, 55)  
        Layout.preferredWidth: Math.min(parent.width * 0.9, 400) 
        Layout.bottomMargin: 40  
    }

    SystemButtons {
        id: systemButtons
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: Math.min(root.height / 6, 75)  
        Layout.preferredWidth: Math.min(parent.width * 0.8, 350)  
        exposedSession: input.exposeSession
        Layout.topMargin: 40 
    }
}
