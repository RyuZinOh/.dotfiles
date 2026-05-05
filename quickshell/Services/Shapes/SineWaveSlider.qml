pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Item {
    id: root

    required property real value
    required property real minVal
    required property real maxVal
    required property color accentFill
    required property color trackFill
    property real amplitude: 0.18
    property real frequency: 12
    property real padX: 4
    property int scrubStep: 1
    property bool interactive: true
    property int animationDuration: 80

    signal scrub(int delta)

    readonly property real fillFrac: (value - minVal) / (maxVal - minVal)
    readonly property real dotX: padX + (width - padX * 2) * _animatedFrac
    readonly property real dotY: height / 2 + height * amplitude * Math.sin(dotX / frequency * Math.PI)

    property real _animatedFrac: fillFrac
    Behavior on _animatedFrac {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Canvas {
        id: _canvas
        anchors.fill: parent
        antialiasing: true

        readonly property real cy: root.height / 2
        readonly property real amp: root.height * root.amplitude
        readonly property real split: root.dotX
        readonly property color accent: root.accentFill

        onAccentChanged: requestPaint()
        onSplitChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.lineWidth = 2;
            ctx.lineCap = ctx.lineJoin = "round";

            const freq = root.frequency;
            const pad = root.padX;

            function wavePath(x) {
                return cy + amp * Math.sin(x / freq * Math.PI);
            }

            ctx.strokeStyle = Theme.outlineVariant.toString();
            ctx.beginPath();
            ctx.moveTo(split, cy);
            ctx.lineTo(width - pad, cy);
            ctx.stroke();

            if (split > pad) {
                ctx.strokeStyle = accent.toString();
                ctx.beginPath();
                ctx.moveTo(pad, wavePath(pad));
                for (let x = pad + 1; x <= split; x++)
                    ctx.lineTo(x, wavePath(x));
                ctx.stroke();
            }
        }
    }

    Rectangle {
        width: 14
        height: 14
        radius: 7
        color: root.accentFill
        visible: root.interactive
        x: root.dotX - 7
        y: root.dotY - 7
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        visible: root.interactive
        property real startX: 0
        property real startVal: 0

        onPressed: e => {
            startX = e.x;
            startVal = root.value;
        }
        onPositionChanged: e => {
            const delta = Math.round((e.x - startX) / width * (root.maxVal - root.minVal));
            const newVal = Math.max(root.minVal, Math.min(root.maxVal, Math.round(startVal + delta)));
            if (newVal !== root.value)
                root.scrub(newVal > root.value ? root.scrubStep : -root.scrubStep);
            startX = e.x;
            startVal = root.value;
        }
        onWheel: w => {
            const d = w.angleDelta.y || -w.angleDelta.x;
            root.scrub(d > 0 ? root.scrubStep : -root.scrubStep);
        }
    }
}
