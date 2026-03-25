pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.Services.Theme

Item {
    id: root
    implicitWidth: 780
    implicitHeight: 380

    property MprisPlayer player: null
    property bool componentActive: true

    readonly property string spritePath: "/home/safal726/.cache/safalQuick/music/"
    readonly property string jhonnyDir: spritePath + "jhonny/"
    readonly property string murasakiDir: spritePath + "murasaki/"
    readonly property string devilDir: spritePath + "devil/"

    readonly property bool isPlaying: player !== null && player.playbackState === MprisPlaybackState.Playing

    Component.onDestruction: {
        componentActive = false;
        player = null;
    }

    Repeater {
        model: Mpris.players
        delegate: Item {
            required property MprisPlayer modelData
            required property int index
            width: 0
            height: 0
            visible: false

            Component.onCompleted: {
                if (!root.player && root.componentActive)
                    root.player = modelData;
            }
            Component.onDestruction: {
                if (!root.componentActive || root.player !== modelData)
                    return;
                root.player = null;
                for (var i = 0; i < Mpris.players.values.length; i++) {
                    if (Mpris.players.values[i] !== modelData) {
                        root.player = Mpris.players.values[i];
                        break;
                    }
                }
            }
        }
    }

    Timer {
        running: root.componentActive && root.isPlaying
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    Connections {
        target: root.player
        function onUniqueIdChanged() {
            squiggleTrack.targetWidth = 0;
            root.resetJohnny();
        }
    }

    Connections {
        target: root
        function onIsPlayingChanged() {
            root.resetJohnny();
        }
    }

    function resetJohnny() {
        johnnySprite.phase = 0;
        johnnySprite.frame = 0;
        johnnySprite.introComplete = false;
    }

    function formatTime(s) {
        if (!s || s < 0){
            return "0:00";
        }
        return Math.floor(s / 60) + ":" + (Math.floor(s % 60) < 10 ? "0" : "") + Math.floor(s % 60);
    }

    ClippingRectangle {
        id: mainContainer
        x: 110
        y: 140
        width: 530
        height: 220
        radius: 20
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1
        z: 1

        Image {
            anchors.fill: parent
            source: root.player ? root.player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            cache: true
            opacity: 0.55
            visible: source !== ""
            Component.onDestruction: source = ""
        }

        AnimatedImage {
            id: animatedBg
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            width: 80
            height: 80
            source: root.isPlaying && root.componentActive ? Qt.resolvedUrl("../../Assets/evernight.gif") : ""
            fillMode: Image.PreserveAspectCrop
            playing: source !== ""
            smooth: true
            asynchronous: true
            cache: false
            opacity: 0.75
            Component.onDestruction: {
                playing = false;
                source = "";
            }
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0.25)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.45)
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "404"
            font.pixelSize: 72
            font.weight: Font.Bold
            color: Theme.onSurfaceVariant
            opacity: 0.2
            visible: !root.player
        }

        Item {
            id: content
            anchors {
                left: parent.left
                leftMargin: 24
                right: parent.right
                rightMargin: 24
                top: parent.top
                topMargin: 20
                bottom: parent.bottom
                bottomMargin: 20
            }
            visible: root.player !== null

            Text {
                id: trackTitle
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                text: root.player?.trackTitle || "Unknown Title"
                font.pixelSize: 22
                font.weight: Font.Bold
                color: Theme.onSurface
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
            }

            Text {
                id: trackArtist
                anchors {
                    left: parent.left
                    right: parent.right
                    top: trackTitle.bottom
                    topMargin: 4
                }
                text: root.player?.trackArtist || "Unknown Artist"
                font.pixelSize: 16
                color: Theme.onSurfaceVariant
                elide: Text.ElideRight
            }

            Text {
                anchors {
                    right: parent.right
                    bottom: squiggleTrack.top
                    bottomMargin: 5
                }
                text: root.player ? (root.formatTime(root.player.position) + " / " + root.formatTime(root.player.length)) : "0:00 / 0:00"
                font.pixelSize: 13
                color: Theme.onSurfaceVariant
            }

            Item {
                id: squiggleTrack
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: controlsRow.top
                    bottomMargin: 14
                }
                height: 14
                clip: true

                property real targetWidth: 0
                property real phase: 0

                Connections {
                    target: root.player
                    function onPositionChanged() {
                        var len = root.player ? root.player.length : 0;
                        squiggleTrack.targetWidth = len > 0 ? Math.min((root.player.position / len) * squiggleTrack.width, squiggleTrack.width) : 0;
                    }
                }

                NumberAnimation on phase {
                    from: 0
                    to: Math.PI * 2
                    duration: 900
                    loops: Animation.Infinite
                    running: root.isPlaying
                }

                Behavior on targetWidth {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.Linear
                    }
                }

                Shape {
                    width: squiggleTrack.targetWidth
                    height: squiggleTrack.height
                    clip: true
                    layer.enabled: true
                    layer.samples: 4
                    ShapePath {
                        strokeWidth: 2.2
                        strokeColor: Theme.primaryColor
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        joinStyle: ShapePath.RoundJoin
                        PathSvg {
                            path: {
                                const W = squiggleTrack.width;
                                const cy = squiggleTrack.height / 2;
                                const amp = squiggleTrack.height * 0.38;
                                const freq = 12;
                                const ph = squiggleTrack.phase;
                                let d = `M 0 ${cy}`;
                                for (let x = 1; x <= W; x += 2){
                                    d += ` L ${x} ${cy + amp * Math.sin(x / freq * Math.PI + ph)}`;
                                }
                                return d;
                            }
                        }
                    }
                }
            }

            Row {
                id: controlsRow
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                }
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: prevMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                    border.color: Theme.outlineVariant
                    border.width: 1
                    visible: root.player?.canGoPrevious ?? false
                    Text {
                        anchors.centerIn: parent
                        text: "⏮"
                        font.pixelSize: 17
                        color: Theme.onSurface
                    }
                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.player?.previous()
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                Rectangle {
                    width: 44
                    height: 44
                    radius: playMouse.containsMouse ? 22 : 12
                    color: playMouse.containsMouse ? Theme.primaryFixedDim : Theme.primaryColor
                    Behavior on radius {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: root.isPlaying ? "⏸" : "▶"
                        font.pixelSize: 20
                        color: Theme.onPrimary
                    }
                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.player?.togglePlaying()
                    }
                }

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: nextMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                    border.color: Theme.outlineVariant
                    border.width: 1
                    visible: root.player?.canGoNext ?? false
                    Text {
                        anchors.centerIn: parent
                        text: "⏭"
                        font.pixelSize: 17
                        color: Theme.onSurface
                    }
                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.player?.next()
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }
        }
    }

    Item {
        id: johnnySprite
        x: 20
        y: 220
        width: 90
        height: 185
        z: 2

        property int phase: 0
        property int frame: 0
        property bool introComplete: false

        readonly property var phaseFrames: [[root.jhonnyDir + "jhonny_entry1.png", root.jhonnyDir + "jhonny_entry2.png", root.jhonnyDir + "jhonny_entry3.png"], [root.jhonnyDir + "entryeffect.png"], [root.jhonnyDir + "jhonnyBeg1.png", root.jhonnyDir + "jhonnyBeg2.png", root.jhonnyDir + "jhonnyBeg3.png", root.jhonnyDir + "jhonnyBeg4.png", root.jhonnyDir + "jhonnyBeg5.png"], [root.jhonnyDir + "jhonnyBeg5effect1.png", root.jhonnyDir + "jhonnyBeg5effect2.png"], [root.jhonnyDir + "jhonnyAfterBeg1.png", root.jhonnyDir + "jhonnyAfterBeg2.png", root.jhonnyDir + "jhonnyAfterBeg3.png", root.jhonnyDir + "jhonnyAfterBeg4.png", root.jhonnyDir + "jhonnyAfterBeg5.png", root.jhonnyDir + "jhonnyAfterBeg6.png"], [root.jhonnyDir + "jhonnyAfterBegE1.png", root.jhonnyDir + "jhonnyAfterBegE2.png"], [root.jhonnyDir + "jhonnydance1.png", root.jhonnyDir + "jhonnydance2.png", root.jhonnyDir + "jhonnydance3.png", root.jhonnyDir + "jhonnydance4.png", root.jhonnyDir + "jhonnydance5.png", root.jhonnyDir + "jhonnydance6.png", root.jhonnyDir + "jhonnydance7.png", root.jhonnyDir + "jhonnydance8.png", root.jhonnyDir + "jhonnydance9.png"], [root.jhonnyDir + "jhonnyBeg1.png"]]

        readonly property bool isEffectPhase: phase === 1 || phase === 3 || phase === 5

        Image {
            anchors.fill: parent
            source: {
                var p = johnnySprite.phase, f = johnnySprite.frame, frames = johnnySprite.phaseFrames;
                if (!johnnySprite.isEffectPhase) {
                    var a = frames[p];
                    return (a && f < a.length) ? a[f] : "";
                }
                var prev = frames[p - 1];
                return prev ? prev[prev.length - 1] : "";
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
        }

        Image {
            x: parent.width - 4
            y: -20
            width: 44
            height: 44
            source: {
                var p = johnnySprite.phase, f = johnnySprite.frame, frames = johnnySprite.phaseFrames;
                if (!johnnySprite.isEffectPhase){
                    return "";
                }
                var a = frames[p];
                return (a && f < a.length) ? a[f] : "";
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
            visible: source !== ""
        }

        Timer {
            running: root.componentActive && (!johnnySprite.introComplete || root.isPlaying)
            interval: 220
            repeat: true
            onTriggered: {
                var frames = johnnySprite.phaseFrames[johnnySprite.phase];
                if (johnnySprite.frame < frames.length - 1) {
                    johnnySprite.frame++;
                } else {
                    johnnySprite.frame = 0;
                    if (!johnnySprite.introComplete) {
                        if (johnnySprite.phase < 6){
                            johnnySprite.phase++;
                        }
                        else{
                            johnnySprite.introComplete = true;
                        }
                    }
                }
            }
        }

        onIntroCompleteChanged: {
            if (introComplete && !root.isPlaying) {
                phase = 7;
                frame = 0;
            }
        }
    }

    Item {
        id: murasakiSprite
        x: 620
        y: 220
        width: 90
        height: 185
        z: 3

        property int frame: 0
        readonly property var bodyFrames: [root.murasakiDir + "murasaki1.png", root.murasakiDir + "murasaki2.png", root.murasakiDir + "murasaki3.png", root.murasakiDir + "murasaki4.png"]
        readonly property var effectForFrame: [root.murasakiDir + "murasakie1.png", root.murasakiDir + "murasakie2.png", root.murasakiDir + "murasakie3.png", root.murasakiDir + "murasakie4.png"]

        Image {
            anchors.fill: parent
            source: {
                var a = murasakiSprite.bodyFrames, f = murasakiSprite.frame;
                return (a && f < a.length) ? a[f] : "";
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
        }

        Timer {
            running: root.componentActive && root.isPlaying
            interval: 240
            repeat: true
            onTriggered: murasakiSprite.frame = (murasakiSprite.frame + 1) % murasakiSprite.bodyFrames.length
        }
    }

    Image {
        x: murasakiSprite.x + (murasakiSprite.width / 2) - (width / 2)
        y: murasakiSprite.y - height + 4
        width: 44
        height: 44
        source: {
            var a = murasakiSprite.effectForFrame, f = murasakiSprite.frame;
            return (root.isPlaying && a && f < a.length) ? a[f] : "";
        }
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
        visible: source !== ""
        z: 4
    }

    Image {
        x: murasakiSprite.x + murasakiSprite.width - 8
        y: murasakiSprite.y - 30
        width: 38
        height: 38
        source: (root.isPlaying && murasakiSprite.frame === 3) ? root.murasakiDir + "murasakie5.png" : ""
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
        visible: source !== ""
        z: 4
    }

    Item {
        id: devilSprite
        x: 320
        y: 28
        width: 110
        height: 115
        z: 3

        property int frame: 0
        readonly property var frames: [root.devilDir + "devil1.png", root.devilDir + "devil2.png", root.devilDir + "devil3.png", root.devilDir + "devil4.png", root.devilDir + "devil5.png", root.devilDir + "devil6.png", root.devilDir + "devil7.png", root.devilDir + "devil8.png", root.devilDir + "devil9.png", root.devilDir + "devil10.png", root.devilDir + "devil11.png", root.devilDir + "devil12.png"]

        Image {
            anchors.fill: parent
            source: {
                var a = devilSprite.frames, f = devilSprite.frame;
                return (a && f < a.length) ? a[f] : "";
            }
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
        }

        Timer {
            running: root.componentActive && root.isPlaying
            interval: 200
            repeat: true
            onTriggered: devilSprite.frame = (devilSprite.frame + 1) % devilSprite.frames.length
        }
    }
}
