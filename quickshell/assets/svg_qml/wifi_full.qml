// Generated from SVG file assets/wifi1.svg
import QtQuick
import QtQuick.VectorImage
import QtQuick.VectorImage.Helpers
import QtQuick.Shapes

Item {
    implicitWidth: 48
    implicitHeight: 48
    component AnimationsInfo : QtObject
    {
        property bool paused: false
        property int loops: 1
        signal restart()
    }
    property AnimationsInfo animations : AnimationsInfo {}
    transform: [
        Translate { x: 0; y: 960 },
        Scale { xScale: width / 960; yScale: height / 960 }
    ]
    id: __qt_toplevel
    Shape {
        id: _qt_node0
        ShapePath {
            id: _qt_shapePath_0
            strokeColor: "transparent"
            fillColor: "#ffffffff"
            fillRule: ShapePath.WindingFill
            PathSvg { path: "M 480 -127 C 456 -127 435 -136 417 -154 C 399 -172 390 -193 390 -217 C 390 -241 399 -262 417 -280 C 435 -298 456 -307 480 -307 C 504 -307 525 -298 543 -280 C 561 -262 570 -241 570 -217 C 570 -193 561 -172 543 -154 C 525 -136 504 -127 480 -127 " }
        }
    }
}
