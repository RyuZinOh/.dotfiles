pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property int alignment: 0
    property real radius: 50
    property color color: "lightgray"
    default property alias content: contentWrapper.data

    Loader {
        anchors.fill: parent
        asynchronous: true
        sourceComponent: {
            const shapes = [attachedTop, attachedBottom];
            return root.alignment >= 0 && root.alignment < 2 ? shapes[root.alignment] : null;
        }
    }

    Item {
        id: contentWrapper

        anchors {
            fill: parent
            leftMargin: root.radius
            rightMargin: root.radius
        }

    }

    Component {
        id: attachedTop

        BubbleShape {
            PathArc {
                x: root.radius
                y: Math.min(root.radius, root.height / 2)
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
            }

            PathLine {
                x: root.radius
                y: Math.max(root.height - root.radius, root.height / 2)
            }

            PathArc {
                x: 2 * root.radius
                y: root.height
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width - 2 * root.radius
                y: root.height
            }

            PathArc {
                x: root.width - root.radius
                y: Math.max(root.height - root.radius, root.height / 2)
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width - root.radius
                y: Math.min(root.radius, root.height / 2)
            }

            PathArc {
                x: root.width
                y: 0
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
            }

            PathLine {
                x: 0
                y: 0
            }

        }

    }

    Component {
        id: attachedBottom

        BubbleShape {
            shapePath.startX: 0
            shapePath.startY: root.height

            PathArc {
                x: root.radius
                y: Math.max(root.height - root.radius, root.height / 2)
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.radius
                y: Math.min(root.radius, root.height / 2)
            }

            PathArc {
                x: 2 * root.radius
                y: 0
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
            }

            PathLine {
                x: root.width - 2 * root.radius
                y: 0
            }

            PathArc {
                x: root.width - root.radius
                y: Math.min(root.radius, root.height / 2)
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
            }

            PathLine {
                x: root.width - root.radius
                y: Math.max(root.height - root.radius, root.height / 2)
            }

            PathArc {
                x: root.width
                y: root.height
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: 0
                y: root.height
            }

        }

    }

    component BubbleShape: Shape {
        default property alias pathElements: shapePath.pathElements
        property alias shapePath: shapePath

        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true

        ShapePath {
            id: shapePath

            pathHints: ShapePath.PathSolid | ShapePath.PathNonIntersecting
            fillColor: root.color
            strokeWidth: -1
        }

    }

}
