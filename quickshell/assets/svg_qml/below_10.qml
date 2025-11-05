// Generated from SVG file assets/below_10.svg
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
            PathSvg { path: "M 130 -240 C 105 -240 83.75 -248.75 66.25 -266.25 C 48.75 -283.75 40 -305 40 -330 L 40 -630 C 40 -655 48.75 -676.25 66.25 -693.75 C 83.75 -711.25 105 -720 130 -720 L 750 -720 C 775 -720 796.25 -711.25 813.75 -693.75 C 831.25 -676.25 840 -655 840 -630 L 840 -330 C 840 -305 831.25 -283.75 813.75 -266.25 C 796.25 -248.75 775 -240 750 -240 L 130 -240 M 130 -300 L 750 -300 C 758.5 -300 765.627 -302.877 771.38 -308.63 C 777.127 -314.377 780 -321.5 780 -330 L 780 -630 C 780 -638.5 777.127 -645.627 771.38 -651.38 C 765.627 -657.127 758.5 -660 750 -660 L 130 -660 C 121.5 -660 114.377 -657.127 108.63 -651.38 C 102.877 -645.627 100 -638.5 100 -630 L 100 -330 C 100 -321.5 102.877 -314.377 108.63 -308.63 C 114.377 -302.877 121.5 -300 130 -300 M 870 -387 L 870 -573 L 890 -573 C 898 -573 905 -570 911 -564 C 917 -558 920 -551 920 -543 L 920 -417 C 920 -409 917 -402 911 -396 C 905 -390 898 -387 890 -387 L 870 -387 M 130 -330 L 130 -630 L 190 -630 L 190 -330 L 130 -330 " }
        }
    }
}
