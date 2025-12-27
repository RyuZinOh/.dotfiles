import QtQuick
import QtQuick.Layouts

/*
Now, this is just a content with no container, popup is handled by the TopJesus!!
*/
Item {
    id: root
    implicitWidth: 540
    implicitHeight: 140

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 12

        RowLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 12

            SystemUsage {
                type: "memory"
                Layout.fillWidth: true
                Layout.preferredHeight: 140
            }

            SystemUsage {
                type: "cpu"
                Layout.fillWidth: true
                Layout.preferredHeight: 140
            }

            SystemUsage {
                type: "temp"
                Layout.fillWidth: true
                Layout.preferredHeight: 140
            }
        }
    }
}
