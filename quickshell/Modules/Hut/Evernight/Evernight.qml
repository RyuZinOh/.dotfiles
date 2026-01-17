import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import qs.Services.Theme

Item {
    id: root
    implicitWidth: mainContainer.width
    implicitHeight: mainContainer.height

    property MprisPlayer player: null
    property bool componentActive: true

    Component.onDestruction: {
        componentActive = false;
        positionTimer.running = false;
        root.player = null;
    }

    Repeater {
        model: Mpris.players
        delegate: Item {
            required property MprisPlayer modelData

            width: 0
            height: 0
            visible: false

            Component.onCompleted: {
                if (!root.player && root.componentActive) {
                    root.player = modelData;
                }
            }

            Component.onDestruction: {
                if (!root.componentActive) {
                    return;
                }

                if (root.player === modelData) {
                    root.player = null;
                    for (var i = 0; i < Mpris.players.length; i++) {
                        if (Mpris.players[i] !== modelData) {
                            root.player = Mpris.players[i];
                            break;
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: positionTimer
        running: root.player && root.player.playbackState === MprisPlaybackState.Playing && root.componentActive
        interval: 500
        repeat: true
        onTriggered: {
            if (root.player && root.componentActive) {
                root.player.positionChanged();
            }
        }
    }

    Rectangle {
        id: mainContainer
        width: 350
        height: 150
        radius: 16
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1
        clip: true

        Loader {
            id: albumArtLoader
            anchors.fill: parent
            active: root.player && root.player.trackArtUrl !== undefined && root.player.trackArtUrl !== ""
            asynchronous: true

            sourceComponent: Item {
                anchors.fill: parent

                Image {
                    id: albumArtBg
                    anchors.fill: parent
                    source: (root.player && root.player.trackArtUrl) ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true
                    cache: true
                    visible: false

                    Component.onDestruction: {
                        source = "";
                    }
                }

                Rectangle {
                    id: albumMask
                    anchors.fill: parent
                    radius: mainContainer.radius
                    visible: false
                }

                OpacityMask {
                    anchors.fill: parent
                    source: albumArtBg
                    maskSource: albumMask
                    opacity: 0.3
                }
            }
        }

        Loader {
            id: animatedBgLoader
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * 0.4
            active: root.player !== null && root.player.playbackState === MprisPlaybackState.Playing && componentActive
            asynchronous: true

            sourceComponent: Item {
                anchors.fill: parent

                AnimatedImage {
                    id: animatedBg
                    anchors.fill: parent
                    source: Qt.resolvedUrl("../../../Assets/evernight.gif")
                    fillMode: Image.PreserveAspectCrop
                    playing: true
                    smooth: true
                    asynchronous: true
                    cache: false
                    visible: false

                    Component.onDestruction: {
                        playing = false;
                        source = "";
                    }
                }

                Rectangle {
                    id: animMask
                    anchors.fill: parent
                    radius: 0
                    visible: false
                }

                OpacityMask {
                    anchors.fill: parent
                    source: animatedBg
                    maskSource: animMask
                    opacity: 0.6
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0.4)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 0.6)
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "404"
            font.pixelSize: 64
            font.weight: Font.Bold
            color: Theme.onSurfaceVariant
            opacity: 0.3
            visible: !root.player && componentActive
        }

        Loader {
            id: contentLoader
            anchors {
                left: parent.left
                leftMargin: 20
                right: parent.right
                rightMargin: 20
                top: parent.top
                topMargin: 16
                bottom: parent.bottom
                bottomMargin: 16
            }
            active: root.player !== null && componentActive
            asynchronous: true

            sourceComponent: Item {
                anchors.fill: parent

                Text {
                    id: trackTitle
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    text: (root.player && root.player.trackTitle) ? root.player.trackTitle : "Unknown Title"
                    font.pixelSize: 16
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
                    text: (root.player && root.player.trackArtist) ? root.player.trackArtist : "Unknown Artist"
                    font.pixelSize: 12
                    color: Theme.onSurfaceVariant
                    elide: Text.ElideRight
                }

                Text {
                    id: timeDisplay
                    anchors {
                        right: parent.right
                        bottom: progressBarBg.top
                        bottomMargin: 6
                    }
                    text: {
                        var pos = (root.player && root.player.position) ? root.player.position : 0;
                        var len = (root.player && root.player.length) ? root.player.length : 0;
                        return formatTime(pos) + " / " + formatTime(len);
                    }
                    font.pixelSize: 10
                    color: Theme.onSurfaceVariant
                    opacity: 0.8
                }

                Rectangle {
                    id: progressBarBg
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: controlsRow.top
                        bottomMargin: 12
                    }
                    height: 4
                    radius: 2
                    color: Theme.surfaceContainerHighest
                    opacity: 0.5

                    Rectangle {
                        id: progressBar
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        radius: parent.radius
                        color: Theme.primaryColor

                        property real currentPosition: (root.player && root.player.position) ? root.player.position : 0
                        property real trackLength: (root.player && root.player.length) ? root.player.length : 1

                        width: {
                            if (trackLength > 0) {
                                return Math.min((currentPosition / trackLength) * parent.width, parent.width);
                            }
                            return 0;
                        }

                        Behavior on width {
                            SmoothedAnimation {
                                duration: 500
                                velocity: -1
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
                    spacing: 10

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: prevMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                        border.color: Theme.outlineVariant
                        border.width: 1
                        visible: root.player && root.player.canGoPrevious

                        Text {
                            anchors.centerIn: parent
                            text: "⏮"
                            font.pixelSize: 16
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

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 40
                        radius: playMouse.containsMouse ? 20 : 10
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
                            text: {
                                if (root.player && root.player.playbackState === MprisPlaybackState.Playing) {
                                    return "⏸";
                                }
                                return "▶";
                            }
                            font.pixelSize: 18
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
                        width: 32
                        height: 32
                        radius: 16
                        color: nextMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                        border.color: Theme.outlineVariant
                        border.width: 1
                        visible: root.player && root.player.canGoNext

                        Text {
                            anchors.centerIn: parent
                            text: "⏭"
                            font.pixelSize: 16
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

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                }
            }
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";
        var mins = Math.floor(seconds / 60);
        var secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }
}
