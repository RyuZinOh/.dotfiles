pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    required property real value
    required property real minVal
    required property real maxVal
    required property color accentFill
    required property color trackFill
    signal scrub(int delta)
    readonly property real frac: Math.max(0, Math.min(1, (value - minVal) / (maxVal - minVal)))
    readonly property real trackH: 3
    readonly property real thumbW: 3
    readonly property real thumbH: 16
    readonly property real gap: 5
    Item {
        anchors.fill: parent
        Item {
            id: inner
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: root.thumbH
            readonly property real availW: width - root.thumbW
            readonly property real thumbX: root.frac * availW
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                width: Math.max(0, inner.thumbX - root.gap)
                height: root.trackH
                bottomLeftRadius: 20
                topLeftRadius: 20
                color: root.accentFill
                visible: root.frac > 0
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: inner.thumbX + root.thumbW + root.gap
                width: Math.max(0, inner.availW - inner.thumbX - root.gap)
                height: root.trackH
                topRightRadius: 20
                bottomRightRadius: 20
                color: root.trackFill
                visible: root.frac < 1
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: inner.thumbX
                width: root.thumbW
                height: root.thumbH
                radius: 2
                color: root.accentFill
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                onWheel: w => {
                    const d = w.angleDelta.y || -w.angleDelta.x;
                    if (d !== 0)
                        root.scrub(d > 0 ? 1 : -1);
                }
            }
        }
    }
}
