pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    implicitWidth: 320
    implicitHeight: col.implicitHeight

    Column {
        id: col
        anchors.fill: parent
        spacing: 8
        Uptime {}
        PowerProfiles {}
        MediaSliders {}
    }
}
