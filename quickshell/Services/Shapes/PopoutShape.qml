import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property int style: 0
    property int alignment: 0
    property int radius: 50
    property color color: "lightgray"

    default property alias content: wrapper.data

    layer.enabled: true
    layer.samples: 4

    readonly property real halfW: width / 2
    readonly property real halfH: height / 2
    readonly property real thirdH: height / 3
    readonly property real r: radius
    readonly property real r2: radius * 2
    readonly property real clampedRW: Math.min(r, halfW)
    readonly property real clampedRH: Math.min(r, halfH)
    readonly property real clampedRH3: Math.min(r, thirdH)

    Loader {
        anchors.fill: parent
        active: style === 1
        asynchronous: false

        sourceComponent: switch (alignment) {
        case 0:
            return attachedTop;
        case 1:
            return attachedTopRight;
        case 2:
            return attachedRight;
        case 3:
            return attachedBottomRight;
        case 4:
            return attachedBottom;
        case 5:
            return attachedBottomLeft;
        case 6:
            return attachedLeft;
        case 7:
            return attachedTopLeft;
        default:
            return null;
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: style === 0
        color: root.color
        radius: root.radius
    }

    Item {
        id: wrapper
        anchors.fill: parent
        anchors.margins: root.radius
    }

    component BubbleShape: Shape {
        anchors.fill: parent
        default property alias pathData: path.pathElements
        property alias path: path
        ShapePath {
            id: path
            pathHints: ShapePath.PathFillOnRight | ShapePath.PathSolid | ShapePath.PathNonIntersecting
            fillColor: root.color
            strokeWidth: -1
        }
    }

    Component {
        id: attachedTop
        BubbleShape {
            PathArc {
                x: r
                y: clampedRH
                radiusX: r
                radiusY: clampedRH
            }
            PathLine {
                x: r
                y: Math.max(height - r, halfH)
            }
            PathArc {
                x: r2
                y: height
                radiusX: r
                radiusY: clampedRH
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width - r2
                y: height
            }
            PathArc {
                x: width - r
                y: Math.max(height - r, halfH)
                radiusX: r
                radiusY: clampedRH
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width - r
                y: clampedRH
            }
            PathArc {
                x: width
                radiusX: r
                radiusY: clampedRH
            }
        }
    }

    Component {
        id: attachedTopRight
        BubbleShape {
            PathArc {
                x: r
                y: clampedRH3
                radiusX: r
                radiusY: clampedRH3
            }
            PathLine {
                x: r
                y: Math.max(height - r2, thirdH)
            }
            PathArc {
                x: r2
                y: Math.max(height - r, 2 * thirdH)
                radiusX: r
                radiusY: clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width - r
                y: Math.max(height - r, 2 * thirdH)
            }
            PathArc {
                x: width
                y: height
                radiusX: r
                radiusY: clampedRH3
            }
            PathLine {
                x: width
            }
        }
    }
    Component {
        id: attachedBottomRight
        BubbleShape {
            path.startY: height
            PathArc {
                x: r
                y: Math.max(height - r, 2 * thirdH)
                radiusX: r
                radiusY: clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: r
                y: r2
            }
            PathArc {
                x: r2
                y: r
                radiusX: r
                radiusY: clampedRH3
            }
            PathLine {
                x: width - r
                y: r
            }
            PathArc {
                x: width
                radiusX: r
                radiusY: clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width
                y: height
            }
        }
    }
    Component {
        id: attachedTopLeft
        BubbleShape {
            path.startX: width
            PathArc {
                x: width - r
                y: clampedRH3
                radiusX: r
                radiusY: clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width - r
                y: Math.max(height - r2, thirdH)
            }
            PathArc {
                x: width - r2
                y: Math.max(height - r, 2 * thirdH)
                radiusX: r
                radiusY: clampedRH3
            }
            PathLine {
                x: r
                y: Math.max(height - r, 2 * thirdH)
            }
            PathArc {
                x: 0
                y: height
                radiusX: r
                radiusY: clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: 0
            }
        }
    }

    Component {
        id: attachedBottomLeft
        BubbleShape {
            path.startX: width
            path.startY: height
            PathArc {
                x: width - r
                y: Math.max(height - r, 2 * thirdH)
                radiusX: r
                radiusY: clampedRH3
            }
            PathLine {
                x: width - r
                y: r2
            }
            PathArc {
                x: width - r2
                y: r
                radiusX: r
                radiusY: clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: r
                y: r
            }
            PathArc {
                x: 0
                radiusX: r
                radiusY: clampedRH3
            }
            PathLine {
                x: 0
                y: height
            }
        }
    }
    Component {
        id: attachedRight
        BubbleShape {
            path.startX: width
            path.startY: height
            PathArc {
                x: Math.max(width - r, halfW)
                y: height - r
                radiusX: clampedRW
                radiusY: r
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: clampedRW
                y: height - r
            }
            PathArc {
                y: height - r2
                radiusX: clampedRW
                radiusY: r
            }
            PathLine {
                y: r2
            }
            PathArc {
                x: clampedRW
                y: r
                radiusX: clampedRW
                radiusY: r
            }
            PathLine {
                x: Math.max(width - r, halfW)
                y: r
            }
            PathArc {
                x: width
                radiusX: clampedRW
                radiusY: r
                direction: PathArc.Counterclockwise
            }
        }
    }

    Component {
        id: attachedBottom
        BubbleShape {
            path.startY: height
            PathArc {
                x: r
                y: Math.max(height - r, halfH)
                radiusX: r
                radiusY: clampedRH
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: r
                y: clampedRH
            }
            PathArc {
                x: r2
                radiusX: r
                radiusY: clampedRH
            }
            PathLine {
                x: width - r2
            }
            PathArc {
                x: width - r
                y: clampedRH
                radiusX: r
                radiusY: clampedRH
            }
            PathLine {
                x: width - r
                y: Math.max(height - r, halfH)
            }
            PathArc {
                x: width
                y: height
                radiusX: r
                radiusY: clampedRH
                direction: PathArc.Counterclockwise
            }
            PathLine {
                y: height
            }
        }
    }

    Component {
        id: attachedLeft
        BubbleShape {
            PathArc {
                x: clampedRW
                y: r
                radiusX: clampedRW
                radiusY: r
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: Math.max(width - r, halfW)
                y: r
            }
            PathArc {
                x: width
                y: r2
                radiusX: clampedRW
                radiusY: r
            }
            PathLine {
                x: width
                y: height - r2
            }
            PathArc {
                x: Math.max(width - r, halfW)
                y: height - r
                radiusX: clampedRW
                radiusY: r
            }
            PathLine {
                x: clampedRW
                y: height - r
            }
            PathArc {
                x: 0
                y: height
                radiusX: clampedRW
                radiusY: r
                direction: PathArc.Counterclockwise
            }
        }
    }
}
