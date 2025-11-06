import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // Customizable properties
    property int style: 0  // 0: Detached, 1: Attached
    property int alignment: 0  // 0: Top, 1: TopRight, 2: Right, 3: Bottom, 4: Left
    property int radius: 10
    property color color: "lightgray"  // Default background color

    // Default property to be bound to content
    default property alias content: wrapper.data

    layer.enabled: true
    layer.samples: 4  // Default quality layer samples

    Loader {
        anchors.fill: parent
        active: true
        asynchronous: false // this mf was true bitch ass [took my 1h time fucking]

        sourceComponent: {
            if (root.style === 1) {
                // Attached style
                switch (root.alignment) {
                case 0:
                    return attachedShapeTop;
                case 1:
                    return attachedShapeTopRight;
                case 2:
                    return attachedShapeRight;
                case 3:
                    return attachedShapeBottom;
                case 4:
                    return attachedShapeLeft;
                default:
                    return null;
                }
            } else if (root.style === 0) {
                // Detached style
                return detachedShape;
            } else {
                console.warn(`No shapes for style '${root.style}' and alignment '${root.alignment}'!`);
                return null;
            }
        }
    }

    Item {
        id: wrapper
        anchors.fill: parent
        anchors.margins: root.radius  // Use radius for margins for simplicity
    }

    // Base Shape Component
    component BaseShape: Shape {
        anchors.fill: parent

        default property alias data: shapePath.pathElements
        property alias shapePath: shapePath

        ShapePath {
            id: shapePath
            pathHints: ShapePath.PathFillOnRight | ShapePath.PathSolid | ShapePath.PathNonIntersecting
            fillColor: root.color
            strokeWidth: -1
        }
    }

    // Detached Shape
    Component {
        id: detachedShape

        Rectangle {
            anchors.fill: parent
            color: root.color
            radius: root.radius
        }
    }

    // Attached Shapes (Different Alignments)

    Component {
        id: attachedShapeTop

        BaseShape {
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
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
            }
        }
    }

    Component {
        id: attachedShapeTopRight

        BaseShape {
            PathArc {
                x: root.radius
                y: Math.min(root.radius, root.height / 3)
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 3)
            }
            PathLine {
                x: root.radius
                y: Math.max(root.height - 2 * root.radius, root.height / 3)
            }
            PathArc {
                x: 2 * root.radius
                y: Math.max(root.height - root.radius, 2 * root.height / 3)
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 3)
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: root.width - root.radius
                y: Math.max(root.height - root.radius, 2 * root.height / 3)
            }
            PathArc {
                x: root.width
                y: root.height
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 3)
            }
            PathLine {
                x: root.width
            }
        }
    }

    Component {
        id: attachedShapeRight

        BaseShape {
            shapePath.startX: width
            shapePath.startY: height

            PathArc {
                x: Math.max(root.width - root.radius, root.width / 2)
                y: root.height - root.radius
                radiusX: Math.min(root.radius, root.width / 2)
                radiusY: root.radius
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: Math.min(root.radius, root.width / 2)
                y: root.height - root.radius
            }
            PathArc {
                y: root.height - 2 * root.radius
                radiusX: Math.min(root.radius, root.width / 2)
                radiusY: root.radius
            }
            PathLine {
                y: 2 * root.radius
            }
            PathArc {
                x: Math.min(root.radius, root.width / 2)
                y: root.radius
                radiusX: Math.min(root.radius, root.width / 2)
                radiusY: root.radius
            }
            PathLine {
                x: Math.max(root.width - root.radius, root.width / 2)
                y: root.radius
            }
            PathArc {
                x: root.width
                radiusX: Math.min(root.radius, root.width / 2)
                radiusY: root.radius
                direction: PathArc.Counterclockwise
            }
        }
    }

    Component {
        id: attachedShapeBottom

        BaseShape {
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
                radiusX: root.radius
                radiusY: Math.min(root.radius, root.height / 2)
            }
            PathLine {
                x: root.width - 2 * root.radius
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
                y: root.height
            }
        }
    }

    Component {
        id: attachedShapeLeft

        BaseShape {
            PathArc {
                x: Math.min(root.radius, root.width / 2)
                y: root.radius
                radiusX: Math.min(root.radius, root.width / 2)
                radiusY: root.radius
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: Math.max(root.width - root.radius, root.width / 2)
                y: root.radius
            }
            PathArc {
                x: root.width
                y: 2 * root.radius
                radiusX: Math.min(root.radius, root.width / 2)
                radiusY: root.radius
            }
            PathLine {
                x: root.width
                y: root.height - 2 * root.radius
            }
            PathArc {
                x: Math.max(root.width - root.radius, root.width / 2)
                y: root.height - root.radius
                radiusX: Math.min(root.radius, root.width / 2)
                radiusY: root.radius
            }
            PathLine {
                x: Math.min(root.radius, root.width / 2)
                y: root.height - root.radius
            }
            PathArc {
                x: 0
                y: root.height
                radiusX: Math.min(root.radius, root.width / 2)
                radiusY: root.radius
                direction: PathArc.Counterclockwise
            }
        }
    }
}
