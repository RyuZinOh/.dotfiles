import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: dateTime
    
    property string dateFormat: "dddd, MMMM d"
    property string timeFormat: "h:mm ap"
    property color textColor: "white"
    property int dateFontSize: 24
    property int timeFontSize: 48
    
    Timer {
        id: timer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = Qt.formatDateTime(new Date(), timeFormat)
            dateText.text = Qt.formatDateTime(new Date(), dateFormat)
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 5
        
        Text {
            id: timeText
            text: Qt.formatDateTime(new Date(), timeFormat)
            color: textColor
            font.pixelSize: timeFontSize
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            id: dateText
            text: Qt.formatDateTime(new Date(), dateFormat)
            color: textColor
            font.pixelSize: dateFontSize
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
