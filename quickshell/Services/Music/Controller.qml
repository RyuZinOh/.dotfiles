import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import qs.Services.Theme

Item {
    id: root
    implicitWidth: 520
    implicitHeight: 200

    property MprisPlayer player: null

    //detect everything out there available
    Repeater {
        model: Mpris.players
        Item {
            Component.onCompleted: {
                if (!root.player) {
                    root.player = modelData;
                }
            }
        }
    }

    Timer {
        running: root.player?.playbackState === MprisPlaybackState.Playing
        interval: 500
        repeat: true
        onTriggered: {
            if (root.player) {
                progressBar.currentPosition = root.player.position || 0;
            }
        }
    }

    //themed background instead of blur
    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceDim
        radius: 10
    }

    Text {
        anchors.centerIn: parent
        text: "Nothing playing..."
        font.family: "CaskaydiaCove NF"
        font.pixelSize: 14
        color: Theme.onSurfaceVariant
        visible: !root.player
    }

    Item {
        anchors {
            fill: parent
            margins: 16
            topMargin: 12
            bottomMargin: 35
        }
        visible: root.player

        // album art
        Rectangle {
            id: albumArtContainer
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: height
            radius: 6
            color: "transparent"

            Image {
                id: albumArt
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                cache: true
                visible: false
            }

            Rectangle {
                id: mask
                anchors.fill: parent
                radius: parent.radius
                visible: false
            }

            OpacityMask {
                anchors.fill: parent
                source: albumArt
                maskSource: mask
            }

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Theme.surfaceContainerHigh
                visible: !root.player?.trackArtUrl

                Text {
                    anchors.centerIn: parent
                    text: "󰝚"
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 56
                    color: Theme.onSurface
                }
            }
        }

        //Content area
        Item {
            anchors {
                left: albumArtContainer.right
                leftMargin: 18
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            // Track title
            Text {
                id: trackTitle
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                text: root.player?.trackTitle ?? "Unknown Title"
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 17
                font.weight: Font.Bold
                color: Theme.onSurface
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
            }

            //artist
            Text {
                id: trackArtist
                anchors {
                    left: parent.left
                    right: parent.right
                    top: trackTitle.bottom
                    topMargin: 6
                }
                text: root.player?.trackArtist ?? "Unknown Artist"
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 13
                color: Theme.onSurfaceVariant
                elide: Text.ElideRight
            }

            //time display
            /*
              - elapsed
              - total
            */
            Text {
                id: timeDisplay
                anchors {
                    right: parent.right
                    bottom: progressBarBg.top
                    bottomMargin: 5
                }
                text: formatTime(progressBar.currentPosition) + " / " + formatTime(progressBar.trackLength)
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 10
                color: Theme.onSurfaceVariant
            }

            //progress bar
            Rectangle {
                id: progressBarBg
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: controlsRow.top
                    bottomMargin: 10
                }
                height: 4
                radius: 2
                color: Theme.surfaceContainerHighest
                opacity: 1

                Rectangle {
                    id: progressBar
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    radius: parent.radius
                    color: Theme.primaryColor

                    property real currentPosition: root.player?.position ?? 0
                    property real trackLength: root.player?.length ?? 1

                    width: trackLength > 0 ? Math.min((currentPosition / trackLength) * parent.width, parent.width) : 0

                    Behavior on width {
                        SmoothedAnimation {
                            duration: 500
                            velocity: -1
                        }
                    }
                }
            }

            //controllers
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
                    color: prevMouse.containsMouse ? Theme.surfaceBright : "transparent"
                    border.color: Theme.onSurface
                    border.width: 1
                    visible: root.player?.canGoPrevious ?? false

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 16
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
                    width: 42
                    height: 42
                    radius: 21
                    color: playMouse.containsMouse ? Theme.primaryFixedDim : Theme.primaryColor

                    Text {
                        anchors.centerIn: parent
                        text: (root.player?.playbackState === MprisPlaybackState.Playing) ? "󰏤" : "󰐊"
                        font.family: "CaskaydiaCove NF"
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

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: nextMouse.containsMouse ? Theme.surfaceBright : "transparent"
                    border.color: Theme.onSurface
                    border.width: 1
                    visible: root.player?.canGoNext ?? false

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.family: "CaskaydiaCove NF"
                        font.pixelSize: 16
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

    function formatTime(seconds) {
        if (!seconds || seconds < 0) {
            return "0:00";
        }
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }
}
