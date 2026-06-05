pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Mpris
import qs.Services.Theme
import qs.Services.Shapes

Item {
    id: root

    signal playingChanged(bool playing)

    readonly property bool isPlaying: root.player !== null && root.player.playbackState === MprisPlaybackState.Playing

    implicitWidth: root.isPlaying ? 450 : 0
    implicitHeight: 40
    width: implicitWidth
    height: root.isPlaying ? 40 : 0
    visible: width > 0
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    property MprisPlayer player: null

    onIsPlayingChanged: root.playingChanged(isPlaying)

    Repeater {
        id: playersRepeater
        model: Mpris.players
        delegate: Item {
            required property MprisPlayer modelData
            width: 0
            height: 0
            visible: false
            Component.onCompleted: {
                if (!root.player)
                    root.player = modelData;
            }
            Component.onDestruction: {
                if (root.player === modelData) {
                    root.player = null;
                    root.playingChanged(false);
                }
            }
        }
    }

    Timer {
        id: positionTimer
        running: root.isPlaying
        interval: 500
        repeat: true
        onTriggered: {
            if (root.player)
                root.player.positionChanged();
        }
    }

    Row {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 12
        visible: root.isPlaying

        Item {
            id: trackLabelArea
            width: contentRow.width - thumbnailItem.width - progressColumn.width - controlsRow.width - contentRow.spacing * 3
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                spacing: 1

                Item {
                    width: parent.width
                    height: trackTitle.implicitHeight
                    clip: true

                    Text {
                        id: trackTitle
                        text: root.player ? root.player.trackTitle : ""
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.onSurface
                        width: parent.width
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                    }
                }

                Item {
                    width: parent.width
                    height: trackArtist.implicitHeight
                    clip: true
                    visible: trackArtist.text.length > 0

                    Text {
                        id: trackArtist
                        text: root.player ? (root.player.trackArtist || "") : ""
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 10
                        color: Theme.onSurfaceVariant
                        width: parent.width
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Item {
            id: thumbnailItem
            width: 34
            height: 34
            anchors.verticalCenter: parent.verticalCenter

            ShapeCanvas {
                anchors.fill: parent
                roundedPolygon: GetMShapes.get(19)
                color: "transparent"
                imageSource: root.player ? (root.player.trackArtUrl || "") : ""
                borderWidth: 2
                borderColor: Theme.accentColor
            }
        }

        Column {
            id: progressColumn
            width: 140
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                id: timeDisplay
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.formatTime(root.player ? root.player.position : 0) + " / " + root.formatTime(root.player ? root.player.length : 0)
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 9
                color: Theme.onSurfaceVariant
            }

            Item {
                id: progressBarArea
                width: parent.width
                height: 14

                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                property real value: root.player ? root.player.position : 0
                property real minVal: 0
                property real maxVal: root.player && root.player.length > 0 ? root.player.length : 1
                property bool isDragging: false
                property real tempFrac: 0
                property real extrapolatedPosition: value

                Timer {
                    id: smoothTimer
                    running: root.isPlaying && !progressBarArea.isDragging
                    interval: 16
                    repeat: true
                    onTriggered: {
                        if (progressBarArea.extrapolatedPosition < progressBarArea.maxVal)
                            progressBarArea.extrapolatedPosition += 0.016;
                    }
                }

                onValueChanged: {
                    extrapolatedPosition = value;
                }

                property real frac: isDragging ? tempFrac : (maxVal > 0 ? Math.max(0, Math.min(1, (extrapolatedPosition - minVal) / (maxVal - minVal))) : 0)
                property color activeColor: Theme.primaryColor
                property color inactiveColor: Theme.surfaceContainerHighest
                property real waveAnimationPhase: 0
                property int waveAmplitude: 2

                signal scrub(int delta)
                onScrub: delta => {
                    if (root.player) {
                        let newPos = root.player.position + (delta * 5);
                        root.player.position = Math.max(0, Math.min(maxVal, newPos));
                    }
                }

                NumberAnimation on waveAnimationPhase {
                    running: root.isPlaying
                    from: 0
                    to: Math.PI * 2
                    duration: 1500
                    loops: Animation.Infinite
                }

                Canvas {
                    id: wavyCanvas
                    anchors.fill: parent
                    antialiasing: true
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        var centerPos = width * progressBarArea.frac;
                        var padding = 4;
                        var waveEndX = Math.max(padding, centerPos - 6);
                        if (waveEndX > padding) {
                            ctx.strokeStyle = progressBarArea.activeColor;
                            ctx.lineWidth = 3;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";
                            ctx.beginPath();
                            var period = 30;
                            for (var x = padding; x <= waveEndX; x++) {
                                var yOffset = Math.sin((x / period) * Math.PI * 2 + progressBarArea.waveAnimationPhase) * progressBarArea.waveAmplitude;
                                if (x === padding)
                                    ctx.moveTo(x, height / 2 + yOffset);
                                else
                                    ctx.lineTo(x, height / 2 + yOffset);
                            }
                            ctx.stroke();
                        }
                    }
                    Connections {
                        target: progressBarArea
                        function onFracChanged() {
                            wavyCanvas.requestPaint();
                        }
                        function onWaveAnimationPhaseChanged() {
                            wavyCanvas.requestPaint();
                        }
                    }
                }

                Canvas {
                    id: inactiveCanvas
                    anchors.fill: parent
                    antialiasing: true
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        var centerPos = width * progressBarArea.frac;
                        var inactiveStartX = centerPos + 6;
                        if (inactiveStartX < width) {
                            ctx.strokeStyle = progressBarArea.inactiveColor;
                            ctx.lineWidth = 3;
                            ctx.lineCap = "round";
                            ctx.beginPath();
                            ctx.moveTo(inactiveStartX, height / 2);
                            ctx.lineTo(width, height / 2);
                            ctx.stroke();
                        }
                    }
                    Connections {
                        target: progressBarArea
                        function onFracChanged() {
                            inactiveCanvas.requestPaint();
                        }
                    }
                }

                Rectangle {
                    width: 3
                    height: 12
                    radius: 2
                    color: progressBarArea.activeColor
                    anchors.verticalCenter: parent.verticalCenter
                    x: Math.min(Math.max(0, (parent.width * progressBarArea.frac) - (width / 2)), parent.width - width)
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    function updateDrag(mouse) {
                        progressBarArea.tempFrac = Math.max(0, Math.min(1, mouse.x / width));
                    }
                    onPressed: mouse => {
                        progressBarArea.isDragging = true;
                        updateDrag(mouse);
                    }
                    onPositionChanged: mouse => {
                        if (pressed)
                            updateDrag(mouse);
                    }
                    onReleased: mouse => {
                        if (root.player && progressBarArea.maxVal > 0) {
                            updateDrag(mouse);
                            root.player.position = progressBarArea.tempFrac * progressBarArea.maxVal;
                        }
                        progressBarArea.isDragging = false;
                    }
                    onWheel: w => {
                        const d = w.angleDelta.y || -w.angleDelta.x;
                        if (d !== 0)
                            progressBarArea.scrub(d > 0 ? 1 : -1);
                    }
                }
            }
        }

        Row {
            id: controlsRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Rectangle {
                width: 26
                height: 26
                radius: width / 2
                color: prevMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                border.color: Theme.outlineColor
                border.width: 2
                visible: root.player ? root.player.canGoPrevious : false
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "\uf04a"
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 13
                    color: Theme.onSurface
                }
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player)
                            root.player.previous();
                    }
                }
            }

            Rectangle {
                width: 30
                height: 30
                radius: width / 2
                color: playMouse.containsMouse ? Theme.primaryContainer : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "\uf04c" : "\uf04b"
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 15
                    color: Theme.onPrimary
                }
                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player)
                            root.player.togglePlaying();
                    }
                }
            }

            Rectangle {
                width: 26
                height: 26
                radius: width / 2
                color: nextMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                border.color: Theme.outlineColor
                border.width: 2
                visible: root.player ? root.player.canGoNext : false
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "\uf04e"
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 13
                    color: Theme.onSurface
                }
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player)
                            root.player.next();
                    }
                }
            }
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }
}
