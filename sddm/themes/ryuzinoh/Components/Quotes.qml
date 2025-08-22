import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: quotes
    
    property string quote: "once you start to rice, u never go back"
    property color textColor: "white"
    property int fontSize: 16
    
    Text {
        text: quote
        color: textColor
        font.pixelSize: fontSize
        font.italic: true
        wrapMode: Text.WordWrap
        width: parent.width
    }
}
