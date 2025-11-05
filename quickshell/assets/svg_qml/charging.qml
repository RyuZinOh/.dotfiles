// Generated from SVG file assets/charging.svg
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
            PathSvg { path: "M 130 -240 C 105 -240 83.75 -248.75 66.25 -266.25 C 48.75 -283.75 40 -305 40 -330 L 40 -630 C 40 -655 48.75 -676.25 66.25 -693.75 C 83.75 -711.25 105 -720 130 -720 L 747 -720 L 699 -660 L 130 -660 C 121.5 -660 114.377 -657.127 108.63 -651.38 C 102.877 -645.627 100 -638.5 100 -630 L 100 -330 C 100 -321.5 102.877 -314.377 108.63 -308.63 C 114.377 -302.877 121.5 -300 130 -300 L 649 -300 L 639 -240 L 130 -240 M 707 -280 L 735 -440 L 600 -440 L 792 -680 L 813 -680 L 785 -520 L 920 -520 L 728 -280 L 707 -280 M 130 -330 L 130 -630 L 675 -630 L 435 -330 L 130 -330 " }
        }
    }
}
