import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import qs.Services.Notification as Services

Item {
    id: root
    anchors.fill: parent

    property int remainingSeconds: 0
    property bool isPaused: false
    property int notifId: -1

    readonly property string bg: "black"
    readonly property string surface: "#100C08"
    readonly property string primary: "#ffffff"
    readonly property string secondary: "whitesmoke"

    MediaPlayer {
        id: sound
        source: "../../../Assets/KuruKuru/kuru.mp3"
        audioOutput: AudioOutput {}
        loops: MediaPlayer.Infinite
    }

    Connections {
        target: Services.NotificationService
        function onHideNotification(id) {
            if (id === notifId) {
                sound.stop();
                notifId = -1;
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: remainingSeconds > 0 && !isPaused
        onTriggered: {
            if (--remainingSeconds === 0) {
                sound.play();
                var notif = {
                    id: Date.now(),
                    summary: titleInput.text || "Timer",
                    body: messageInput.text || "Time's up!",
                    appName: "Timerchan!!",
                    appIcon: Qt.resolvedUrl("../../../Assets/KuruKuru/seseren.gif"),
                    actions: []
                };
                notifId = notif.id;
                Services.NotificationService.activeNotifications.push(notif);
                Services.NotificationService.showNotification(notif);
            }
        }
    }

    function formatTime(s) {
        var h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), sec = s % 60;
        return (h > 0 ? h + ":" : "") + (h > 0 && m < 10 ? "0" : "") + m + ":" + (sec < 10 ? "0" : "") + sec;
    }

    Rectangle {
        anchors.fill: parent
        color: bg

        RowLayout {
            anchors.centerIn: parent
            spacing: 50

            //timer display
            Rectangle {
                Layout.preferredWidth: 350
                Layout.preferredHeight: 200
                color: surface
                radius: 10

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: formatTime(remainingSeconds)
                        color: primary
                        font.pixelSize: 48
                        font.weight: Font.Light
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8
                        visible: remainingSeconds === 0

                        //predefine most use timers
                        Repeater {
                            model: [
                                {
                                    t: "1m",
                                    s: 60
                                },
                                {
                                    t: "5m",
                                    s: 300
                                },
                                {
                                    t: "10m",
                                    s: 600
                                }
                            ]
                            Button {
                                text: modelData.t
                                font.pixelSize: 11
                                hoverEnabled: true
                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: primary
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: bg
                                    implicitHeight: 24
                                    implicitWidth: 40
                                    radius: 10
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: remainingSeconds = modelData.s
                                }
                            }
                        }
                    }
                }
            }

            //controls
            ColumnLayout {
                spacing: 10

                RowLayout {
                    spacing: 8

                    TextField {
                        id: titleInput
                        placeholderText: "Title"
                        leftPadding: 10
                        font.pixelSize: 13
                        enabled: remainingSeconds === 0
                        color: primary
                        placeholderTextColor: secondary
                        background: Rectangle {
                            color: surface
                            implicitWidth: 140
                            implicitHeight: 40
                            radius: 10
                        }
                    }

                    TextField {
                        id: messageInput
                        placeholderText: "Message"
                        font.pixelSize: 13
                        leftPadding: 10
                        enabled: remainingSeconds === 0
                        color: primary
                        placeholderTextColor: secondary
                        background: Rectangle {
                            color: surface
                            implicitWidth: 140
                            implicitHeight: 40
                            radius: 10
                        }
                    }
                }

                RowLayout {
                    spacing: 8
                    //hour
                    SpinBox {
                        id: hoursInput
                        from: 0
                        to: 23
                        enabled: remainingSeconds === 0
                        editable: true
                        contentItem: TextInput {
                            text: hoursInput.textFromValue(hoursInput.value, hoursInput.locale)
                            font.pixelSize: 16
                            color: primary
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            readOnly: !hoursInput.editable
                            anchors.centerIn: parent
                        }
                        background: Rectangle {
                            color: surface
                            implicitWidth: 60
                            implicitHeight: 40
                            radius: 10
                        }
                    }

                    Text {
                        text: ":"
                        color: secondary
                        font.pixelSize: 18
                    }
                    //second
                    SpinBox {
                        id: minutesInput
                        from: 0
                        to: 59
                        enabled: remainingSeconds === 0
                        editable: true
                        contentItem: TextInput {
                            text: minutesInput.textFromValue(minutesInput.value, minutesInput.locale)
                            font.pixelSize: 16
                            color: primary
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            anchors.centerIn: parent
                            readOnly: !minutesInput.editable
                        }
                        background: Rectangle {
                            color: surface
                            implicitWidth: 60
                            implicitHeight: 40
                            radius: 10
                        }
                    }

                    Text {
                        text: ":"
                        color: secondary
                        font.pixelSize: 18
                    }

                    //sec
                    SpinBox {
                        id: secondsInput
                        from: 0
                        to: 59
                        value: 10
                        enabled: remainingSeconds === 0
                        editable: true
                        contentItem: TextInput {
                            text: secondsInput.textFromValue(secondsInput.value, secondsInput.locale)
                            font.pixelSize: 16
                            color: primary
                            anchors.centerIn: parent
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            readOnly: !secondsInput.editable
                        }
                        background: Rectangle {
                            color: surface
                            implicitWidth: 60
                            implicitHeight: 40
                            radius: 10
                        }
                    }
                }

                RowLayout {
                    spacing: 10

                    Button {
                        text: remainingSeconds === 0 ? "Start" : (isPaused ? "Resume" : "Pause")
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        hoverEnabled: true
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: bg
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: primary
                            implicitWidth: 135
                            implicitHeight: 40
                            radius: 10
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (remainingSeconds === 0) {
                                    var total = hoursInput.value * 3600 + minutesInput.value * 60 + secondsInput.value;
                                    if (total > 0) {
                                        remainingSeconds = total;
                                    }
                                } else {
                                    isPaused = !isPaused;
                                }
                            }
                        }
                    }

                    Button {
                        text: "Reset"
                        font.pixelSize: 13
                        hoverEnabled: true
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: primary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: "red"
                            implicitWidth: 135
                            implicitHeight: 40
                            radius: 10
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                remainingSeconds = 0;
                                isPaused = false;
                                sound.stop();
                                if (notifId !== -1) {
                                    Services.NotificationService.dismiss(notifId);
                                    notifId = -1;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
