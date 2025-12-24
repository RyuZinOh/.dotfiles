// Generated from SVG file restart.svg
import QtQuick
import QtQuick.VectorImage
import QtQuick.VectorImage.Helpers
import QtQuick.Shapes

Item {
    id: __qt_toplevel
    implicitWidth: 24
    implicitHeight: 24

    property color fillColor: Theme.onSurface
    component AnimationsInfo: QtObject {
        property bool paused: false
        property int loops: 1
        signal restart
    }
    property AnimationsInfo animations: AnimationsInfo {}
    transform: [
        Translate {
            x: 0
            y: 960
        },
        Scale {
            xScale: width / 960
            yScale: height / 960
        }
    ]
    Shape {
        id: _qt_node0
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            id: _qt_shapePath_0
            strokeColor: "transparent"
            fillColor: __qt_toplevel.fillColor
            fillRule: ShapePath.WindingFill
            PathSvg {
                path: "M 314 -115 C 244.667 -147 188.333 -195.333 145 -260 C 101.667 -324.667 80 -397.667 80 -479 C 80 -496.333 80.8333 -513.333 82.5 -530 C 84.1667 -546.667 87 -563 91 -579 L 45 -552 L 5 -621 L 196 -731 L 306 -541 L 236 -501 L 182 -595 C 174.667 -577 169.167 -558.333 165.5 -539 C 161.833 -519.667 160 -499.667 160 -479 C 160 -414.333 177.667 -355.5 213 -302.5 C 248.333 -249.5 295.333 -210.333 354 -185 L 314 -115 M 620 -600 L 620 -680 L 729 -680 C 698.333 -718 661.333 -747.5 618 -768.5 C 574.667 -789.5 528.667 -800 480 -800 C 443.333 -800 408.667 -794.333 376 -783 C 343.333 -771.667 313.333 -755.667 286 -735 L 246 -805 C 279.333 -828.333 315.667 -846.667 355 -860 C 394.333 -873.333 436 -880 480 -880 C 532.667 -880 583 -870.167 631 -850.5 C 679 -830.833 722 -802.333 760 -765 L 760 -820 L 840 -820 L 840 -600 L 620 -600 M 594 0 L 403 -110 L 513 -300 L 582 -260 L 525 -162 C 603.667 -173.333 669.167 -209 721.5 -269 C 773.833 -329 800 -399.333 800 -480 C 800 -487.333 799.833 -494.167 799.5 -500.5 C 799.167 -506.833 798.333 -513.333 797 -520 L 878 -520 C 878.667 -513.333 879.167 -506.833 879.5 -500.5 C 879.833 -494.167 880 -487.333 880 -480 C 880 -390 853.167 -309.5 799.5 -238.5 C 745.833 -167.5 676 -119.667 590 -95 L 634 -69 L 594 0 "
            }
        }
    }
}
