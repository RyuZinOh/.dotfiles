pragma Singleton

import Quickshell
import QtQuick

/*
singleton remains singleton [once per engine]
*/
Singleton {
    id: root
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    property string time: Qt.formatTime(clock.date, "hh:mm AP")
    property string date: Qt.formatDate(clock.date, "MMMM d, yyyy")
    property string day: Qt.formatDate(clock.date, "dddd")
}
