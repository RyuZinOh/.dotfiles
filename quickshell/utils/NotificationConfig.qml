pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick

QtObject {
    id: root
    property int autoCloseDuration: 5000
    property int enterHeightDuration: 220
    property int enterSlideDuration: 340
    property int exitSlideDuration: 320
    property int exitHeightDuration: 200
    property int expandDuration: 400
    property int progressInterval: 50
    property int collapsedLines: 3
}
