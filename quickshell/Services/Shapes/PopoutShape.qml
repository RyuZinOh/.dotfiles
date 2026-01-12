import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property int alignment: 0
    property int radius: 50
    property color color: "lightgray"

    default property alias content: contentWrapper.data

    layer.enabled: true
    layer.samples: 16
    layer.smooth: true
    antialiasing: true
    smooth: true

    readonly property real _halfW: width * 0.5
    readonly property real _halfH: height * 0.5
    readonly property real _thirdH: height / 3
    readonly property real _r: radius
    readonly property real _r2: radius * 2
    readonly property real _clampedRW: Math.min(_r, _halfW)
    readonly property real _clampedRH: Math.min(_r, _halfH)
    readonly property real _clampedRH3: Math.min(_r, _thirdH)

    Loader {
        anchors.fill: parent
        asynchronous: true

        sourceComponent: {
            const shapes = [attachedTop, attachedTopRight, attachedRight, attachedBottomRight, attachedBottom, attachedBottomLeft, attachedLeft, attachedTopLeft];
            return alignment >= 0 && alignment < 8 ? shapes[alignment] : null;
        }
    }

    Item {
        id: contentWrapper
        anchors.fill: parent
        anchors.margins: root.radius
    }

    component BubbleShape: Shape {
        anchors.fill: parent
        smooth: true
        antialiasing: true
        layer.enabled: true
        layer.smooth: true
        layer.samples: 16

        default property alias pathElements: shapePath.pathElements

        ShapePath {
            id: shapePath
            fillColor: root.color
            // This outline thing still isn't ready yet.. [very unstable like rendering issues].
            strokeColor: "black"
            strokeWidth: 0
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
        }
    }

    Component {
        id: attachedTop
        BubbleShape {
            PathMove {
                x: 0
                y: 0
            }
            PathArc {
                x: _r
                y: _clampedRH
                radiusX: _r
                radiusY: _clampedRH
            }
            PathLine {
                x: _r
                y: Math.max(height - _r, _halfH)
            }
            PathArc {
                x: _r2
                y: height
                radiusX: _r
                radiusY: _clampedRH
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width - _r2
                y: height
            }
            PathArc {
                x: width - _r
                y: Math.max(height - _r, _halfH)
                radiusX: _r
                radiusY: _clampedRH
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width - _r
                y: _clampedRH
            }
            PathArc {
                x: width
                y: 0
                radiusX: _r
                radiusY: _clampedRH
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }

    Component {
        id: attachedTopRight
        BubbleShape {
            PathMove {
                x: 0
                y: 0
            }
            PathArc {
                x: _r
                y: _clampedRH3
                radiusX: _r
                radiusY: _clampedRH3
            }
            PathLine {
                x: _r
                y: Math.max(height - _r2, _thirdH)
            }
            PathArc {
                x: _r2
                y: Math.max(height - _r, 2 * _thirdH)
                radiusX: _r
                radiusY: _clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width - _r
                y: Math.max(height - _r, 2 * _thirdH)
            }
            PathArc {
                x: width
                y: height
                radiusX: _r
                radiusY: _clampedRH3
            }
            PathLine {
                x: width
                y: 0
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }

    Component {
        id: attachedRight
        BubbleShape {
            PathMove {
                x: width
                y: height
            }
            PathArc {
                x: Math.max(width - _r, _halfW)
                y: height - _r
                radiusX: _clampedRW
                radiusY: _r
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: _clampedRW
                y: height - _r
            }
            PathArc {
                x: 0
                y: height - _r2
                radiusX: _clampedRW
                radiusY: _r
            }
            PathLine {
                x: 0
                y: _r2
            }
            PathArc {
                x: _clampedRW
                y: _r
                radiusX: _clampedRW
                radiusY: _r
            }
            PathLine {
                x: Math.max(width - _r, _halfW)
                y: _r
            }
            PathArc {
                x: width
                y: 0
                radiusX: _clampedRW
                radiusY: _r
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width
                y: height
            }
        }
    }

    Component {
        id: attachedBottomRight
        BubbleShape {
            PathMove {
                x: 0
                y: height
            }
            PathArc {
                x: _r
                y: Math.max(height - _r, 2 * _thirdH)
                radiusX: _r
                radiusY: _clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: _r
                y: _r2
            }
            PathArc {
                x: _r2
                y: _r
                radiusX: _r
                radiusY: _clampedRH3
            }
            PathLine {
                x: width - _r
                y: _r
            }
            PathArc {
                x: width
                y: 0
                radiusX: _r
                radiusY: _clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width
                y: height
            }
            PathLine {
                x: 0
                y: height
            }
        }
    }

    Component {
        id: attachedBottom
        BubbleShape {
            PathMove {
                x: 0
                y: height
            }
            PathArc {
                x: _r
                y: Math.max(height - _r, _halfH)
                radiusX: _r
                radiusY: _clampedRH
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: _r
                y: _clampedRH
            }
            PathArc {
                x: _r2
                y: 0
                radiusX: _r
                radiusY: _clampedRH
            }
            PathLine {
                x: width - _r2
                y: 0
            }
            PathArc {
                x: width - _r
                y: _clampedRH
                radiusX: _r
                radiusY: _clampedRH
            }
            PathLine {
                x: width - _r
                y: Math.max(height - _r, _halfH)
            }
            PathArc {
                x: width
                y: height
                radiusX: _r
                radiusY: _clampedRH
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: 0
                y: height
            }
        }
    }

    Component {
        id: attachedBottomLeft
        BubbleShape {
            PathMove {
                x: width
                y: height
            }
            PathArc {
                x: width - _r
                y: Math.max(height - _r, 2 * _thirdH)
                radiusX: _r
                radiusY: _clampedRH3
            }
            PathLine {
                x: width - _r
                y: _r2
            }
            PathArc {
                x: width - _r2
                y: _r
                radiusX: _r
                radiusY: _clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: _r
                y: _r
            }
            PathArc {
                x: 0
                y: 0
                radiusX: _r
                radiusY: _clampedRH3
            }
            PathLine {
                x: 0
                y: height
            }
            PathLine {
                x: width
                y: height
            }
        }
    }

    Component {
        id: attachedLeft
        BubbleShape {
            PathMove {
                x: 0
                y: 0
            }
            PathArc {
                x: _clampedRW
                y: _r
                radiusX: _clampedRW
                radiusY: _r
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: Math.max(width - _r, _halfW)
                y: _r
            }
            PathArc {
                x: width
                y: _r2
                radiusX: _clampedRW
                radiusY: _r
            }
            PathLine {
                x: width
                y: height - _r2
            }
            PathArc {
                x: Math.max(width - _r, _halfW)
                y: height - _r
                radiusX: _clampedRW
                radiusY: _r
            }
            PathLine {
                x: _clampedRW
                y: height - _r
            }
            PathArc {
                x: 0
                y: height
                radiusX: _clampedRW
                radiusY: _r
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }

    Component {
        id: attachedTopLeft
        BubbleShape {
            PathMove {
                x: width
                y: 0
            }
            PathArc {
                x: width - _r
                y: _clampedRH3
                radiusX: _r
                radiusY: _clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: width - _r
                y: Math.max(height - _r2, _thirdH)
            }
            PathArc {
                x: width - _r2
                y: Math.max(height - _r, 2 * _thirdH)
                radiusX: _r
                radiusY: _clampedRH3
            }
            PathLine {
                x: _r
                y: Math.max(height - _r, 2 * _thirdH)
            }
            PathArc {
                x: 0
                y: height
                radiusX: _r
                radiusY: _clampedRH3
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: 0
                y: 0
            }
            PathLine {
                x: width
                y: 0
            }
        }
    }
}
