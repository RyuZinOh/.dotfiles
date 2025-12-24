// Generated from SVG file shutdown.svg
import QtQuick
import QtQuick.VectorImage
import QtQuick.VectorImage.Helpers
import QtQuick.Shapes
import qs.Services.Theme

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
                path: "M 480 -480 C 468.667 -480 459.167 -483.833 451.5 -491.5 C 443.833 -499.167 440 -508.667 440 -520 L 440 -840 C 440 -851.333 443.833 -860.833 451.5 -868.5 C 459.167 -876.167 468.667 -880 480 -880 C 491.333 -880 500.833 -876.167 508.5 -868.5 C 516.167 -860.833 520 -851.333 520 -840 L 520 -520 C 520 -508.667 516.167 -499.167 508.5 -491.5 C 500.833 -483.833 491.333 -480 480 -480 M 480 -120 C 430 -120 383.167 -129.5 339.5 -148.5 C 295.833 -167.5 257.833 -193.167 225.5 -225.5 C 193.167 -257.833 167.5 -295.833 148.5 -339.5 C 129.5 -383.167 120 -430 120 -480 C 120 -520.667 126.667 -560.167 140 -598.5 C 153.333 -636.833 172.667 -672 198 -704 C 205.333 -713.333 214.667 -717.833 226 -717.5 C 237.333 -717.167 247.333 -712.667 256 -704 C 263.333 -696.667 266.667 -687.667 266 -677 C 265.333 -666.333 261.667 -656.333 255 -647 C 237 -623 223.333 -596.667 214 -568 C 204.667 -539.333 200 -510 200 -480 C 200 -402 227.167 -335.833 281.5 -281.5 C 335.833 -227.167 402 -200 480 -200 C 558 -200 624.167 -227.167 678.5 -281.5 C 732.833 -335.833 760 -402 760 -480 C 760 -510.667 755.5 -540.5 746.5 -569.5 C 737.5 -598.5 723.333 -625 704 -649 C 697.333 -657.667 693.667 -667.167 693 -677.5 C 692.333 -687.833 695.667 -696.667 703 -704 C 711 -712 720.667 -716.167 732 -716.5 C 743.333 -716.833 752.667 -712.667 760 -704 C 786 -672 805.833 -637 819.5 -599 C 833.167 -561 840 -521.333 840 -480 C 840 -430 830.5 -383.167 811.5 -339.5 C 792.5 -295.833 766.833 -257.833 734.5 -225.5 C 702.167 -193.167 664.167 -167.5 620.5 -148.5 C 576.833 -129.5 530 -120 480 -120 "
            }
        }
    }
}
