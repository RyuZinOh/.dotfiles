import QtQuick
import QtQuick.Controls

Item {
    id: quotes

    property string quote: "once you start to rice, u never go back"
    property color textColor: "white"
    property int fontSize: 16

    height: quoteText.height

    Text {
        id: quoteText
        anchors.centerIn: parent
        width: parent.width
        text: quote
        color: textColor
        font.pixelSize: fontSize
        font.italic: true
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        opacity: 0.9

        Behavior on text {
            SequentialAnimation {
                NumberAnimation {
                    target: quoteText
                    property: "opacity"
                    to: 0
                    duration: 150
                }
                PropertyAction {
                    target: quoteText
                    property: "text"
                }
                NumberAnimation {
                    target: quoteText
                    property: "opacity"
                    to: 0.9
                    duration: 150
                }
            }
        }
    }
}
