import QtQuick
import QtQuick.Controls

Item {
    id: dateTime

    property string dateFormat: "dddd, MMMM d"
    property string timeFormat: "h:mm ap"
    property color textColor: "white"
    property int dateFontSize: 24
    property int timeFontSize: 48

    width: timeColumn.width
    height: timeColumn.height

    Timer {
        id: timer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = Qt.formatDateTime(new Date(), timeFormat);
            dateText.text = Qt.formatDateTime(new Date(), dateFormat);
        }
    }

    Column {
        id: timeColumn
        spacing: 5

        Text {
            id: timeText
            text: Qt.formatDateTime(new Date(), timeFormat)
            color: textColor
            font.pixelSize: timeFontSize
            font.bold: true
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            id: dateText
            text: Qt.formatDateTime(new Date(), dateFormat)
            color: textColor
            font.pixelSize: dateFontSize
            horizontalAlignment: Text.AlignLeft
        }
    }
}
