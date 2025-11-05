// Generated from SVG file assets/wifi_off.svg
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
            PathSvg { path: "M 703 -343 L 662 -384 L 872 -594 C 814 -639.333 752.5 -675 687.5 -701 C 622.5 -727 553.333 -740 480 -740 C 453.333 -740 427.167 -738.333 401.5 -735 C 375.833 -731.667 350.667 -726.333 326 -719 L 277 -768 C 309.667 -778.667 342.833 -786.667 376.5 -792 C 410.167 -797.333 444.667 -800 480 -800 C 571.333 -800 657.667 -782.333 739 -747 C 820.333 -711.667 894 -662.667 960 -600 L 703 -343 M 480 -202 L 576 -298 L 204 -670 C 184 -659.333 164.333 -647.667 145 -635 C 125.667 -622.333 106.667 -608.667 88 -594 L 480 -202 M 837 -37 L 617 -257 L 480 -120 L 0 -600 C 24 -623.333 49.1667 -644.667 75.5 -664 C 101.833 -683.333 129.333 -700.667 158 -716 L 37 -837 L 80 -880 L 880 -80 L 837 -37 M 390 -484 " }
        }
    }
}
