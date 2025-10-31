import QtQuick
import QtQuick.Layouts
import SddmComponents 2.0 as SDDM

ColumnLayout {
    id: formContainer
    
    SDDM.TextConstants { id: textConstants }
    
    property int p: 0
    property string a: "center"
   
    Layout.alignment: Qt.AlignCenter
    
    Input {
        id: input
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: Math.min(root.height / 12, 55)
        Layout.preferredWidth: Math.min(parent.width * 0.9, 400)
    }
}
