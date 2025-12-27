/*Wrapper for all of my Svgs for usage*/
import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property string name: ""
    property int size: 24
    property color color: "white"

    width: size
    height: size

    Image {
        id: img
        anchors.fill: parent
        source: root.name ? `file:///home/safal726/.cache/safalQuick/svgs/${root.name}.svg` : ""
        sourceSize: Qt.size(root.size, root.size)
        smooth: true
        cache: true
        asynchronous: true
        visible: false
    }

    ColorOverlay {
        anchors.fill: img
        source: img
        color: root.color
        cached: true
    }
}
