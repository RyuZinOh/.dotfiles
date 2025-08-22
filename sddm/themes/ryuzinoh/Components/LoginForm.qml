import QtQuick 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0 as SDDM

ColumnLayout {
    id: formContainer
    SDDM.TextConstants { id: textConstants }

    property int p: config.ScreenPadding || 0
    property string a: config.FormPosition || "center"

   
    Layout.alignment: Qt.AlignCenter

    Input {
        id: input
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: Math.min(root.height / 12, 55)
        Layout.preferredWidth: Math.min(parent.width * 0.9, 400)
        
    }
}
