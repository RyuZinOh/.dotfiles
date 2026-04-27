pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Wayland

Item {
    id: root

    property string shaderPath: "/home/safalski/.cache/safalQuick/nightsoul/bounce/"
    property var captureSource: null
    property bool ready: false

    property vector2d jigglePos: Qt.vector2d(0.5, 0.5)
    property real jiggleTime: 0.0

    visible: false

    function activate(source) {
        root.captureSource = source;
        root.visible = true;
        root.ready = true;
    }

    function deactivate() {
        root.visible = false;
        root.ready = false;
        root.captureSource = null;
        jiggleTimeAnim.stop();
    }

    function triggerJiggle(px, py) {
        if (!root.ready)
            return;
        root.jigglePos = Qt.vector2d(px / root.width, py / root.height);
        root.jiggleTime = 0;
        jiggleTimeAnim.restart();
    }

    NumberAnimation {
        id: jiggleTimeAnim
        target: root
        property: "jiggleTime"
        from: 0
        to: 3
        duration: 3000
        running: false
    }

    ScreencopyView {
        id: screenView
        anchors.fill: parent
        captureSource: root.captureSource
        live: false
        visible: false
    }

    ShaderEffectSource {
        id: fxSource
        sourceItem: screenView
        anchors.fill: parent
        visible: false
    }

    Loader {
        anchors.fill: parent
        active: root.ready
        sourceComponent: Component {
            ShaderEffect {
                anchors.fill: parent

                property variant source: fxSource
                property vector2d mousePos: root.jigglePos
                property real time: root.jiggleTime
                property real intensity: 1.0

                vertexShader: root.shaderPath + "jiggle.vert.qsb"
                fragmentShader: root.shaderPath + "jiggle.frag.qsb"
            }
        }
    }
}
