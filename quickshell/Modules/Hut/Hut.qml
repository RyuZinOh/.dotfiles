/* This one is like a control center something for wifi and stuff management */
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import Quickshell.Widgets
import qs.Services.Theme
import "./Warsa/"
import "./Areuok/"

Item {
    id: root
    property bool isHovered: false
    property color barColor: Theme.surfaceContainerLow
    
    property real collapsedWidth: 0.1
    property real expandedWidth: 380

    property real currentBarWidth: isHovered ? expandedWidth : collapsedWidth
    
    property real maskWidth: isHovered ? expandedWidth : 10

    Behavior on currentBarWidth {
        NumberAnimation { 
            duration: 350; 
            easing.type: Easing.OutCubic 
        }
    }

    width: currentBarWidth
    height: parent?.height ?? 0
    anchors.right: parent.right

    Timer {
        id: unloadTimer
        interval: 700
        onTriggered: if (!root.isHovered) contentLoader.active = false
    }

    onIsHoveredChanged: {
        if (isHovered) {
            unloadTimer.stop()
            contentLoader.active = true
        } else {
            unloadTimer.start()
        }
    }

    component Corner: WrapperItem {
        id: cornerRoot
        property int corner
        property real radius: 20
        property color color

        implicitWidth: radius
        implicitHeight: radius

        Component.onCompleted: {
            switch (corner) {
                case 1:
                    anchors.top = parent.top
                    anchors.right = parent.left
                    rotation = 90
                    break
                case 2:
                    anchors.bottom = parent.bottom
                    anchors.right = parent.left
                    rotation = 180
                    break
            }
        }

        Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 0
                fillColor: cornerRoot.color
                startX: cornerRoot.radius
                PathArc {
                    relativeX: -cornerRoot.radius
                    relativeY: cornerRoot.radius
                    radiusX: cornerRoot.radius
                    radiusY: radiusX
                    direction: PathArc.Counterclockwise
                }
                PathLine { relativeX: 0; relativeY: -cornerRoot.radius }
                PathLine { relativeX: cornerRoot.radius; relativeY: 0 }
            }
        }
    }

    Rectangle {
        id: bar
        anchors.fill: parent
        color: root.barColor
        
        clip: root.currentBarWidth < 5

        Corner {
            corner: 1
            color: root.barColor
        }

        Corner {
            corner: 2
            color: root.barColor
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
           
            active: false
            asynchronous: true
            clip: true

            property real contentOpacity: root.isHovered ? 1 : 0
            property real contentTranslateX: root.isHovered ? 0 : 30
            
            Behavior on contentOpacity {
                NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
            }
            Behavior on contentTranslateX {
                NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
            }

            sourceComponent: Component {
                Item {
                    opacity: contentLoader.contentOpacity
                    transform: Translate { x: contentLoader.contentTranslateX }

                    Column {
                        spacing: 16
                        anchors.horizontalCenter: parent.horizontalCenter

                        Loader {
                            anchors.horizontalCenter: parent.horizontalCenter
                            active: root.isHovered
                            asynchronous: true
                            sourceComponent: Component { Areuok {} }
                        }
                        Loader {
                            anchors.horizontalCenter: parent.horizontalCenter
                            active: root.isHovered
                            asynchronous: true
                            sourceComponent: Component { Warsa {} }
                        }
                    }
                }
            }
        }

        HoverHandler {
            id: hand
            onHoveredChanged: root.isHovered = hovered
        }
    }
}
