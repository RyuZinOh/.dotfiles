// Generated from SVG file assets/wifi3.svg
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
            PathSvg { path: "M 480 -127 C 456 -127 435 -136 417 -154 C 399 -172 390 -193 390 -217 C 390 -241 399 -262 417 -280 C 435 -298 456 -307 480 -307 C 504 -307 525 -298 543 -280 C 561 -262 570 -241 570 -217 C 570 -193 561 -172 543 -154 C 525 -136 504 -127 480 -127 M 232 -357 L 169 -420 C 215.667 -466.667 264.5 -501.667 315.5 -525 C 366.5 -548.333 421.333 -560 480 -560 C 538.667 -560 593.5 -548.333 644.5 -525 C 695.5 -501.667 744.333 -466.667 791 -420 L 728 -357 C 687.333 -397.667 646.333 -426.667 605 -444 C 563.667 -461.333 522 -470 480 -470 C 438 -470 396.333 -461.333 355 -444 C 313.667 -426.667 272.667 -397.667 232 -357 M 63 -526 L 0 -589 C 62 -652.333 134.167 -703.333 216.5 -742 C 298.833 -780.667 386.667 -800 480 -800 C 573.333 -800 661.167 -780.667 743.5 -742 C 825.833 -703.333 898 -652.333 960 -589 L 897 -526 C 838.333 -582 774.167 -626.667 704.5 -660 C 634.833 -693.333 560 -710 480 -710 C 400 -710 325.167 -693.333 255.5 -660 C 185.833 -626.667 121.667 -582 63 -526 " }
        }
    }
}
