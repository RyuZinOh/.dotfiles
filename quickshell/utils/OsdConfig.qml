pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick

QtObject {
    id: root

    property string mode: "volume"
    property int currentValue: 0
    property bool isMuted: false
    property bool isVisible: false

    readonly property int maxLimit: 100
}
