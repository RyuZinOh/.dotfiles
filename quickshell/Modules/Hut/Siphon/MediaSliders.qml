pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import qs.Services.Theme
import qs.Services.Sliders
import qs.utils

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 220

    component ColorBehavior: ColorAnimation {
        duration: 200
    }

    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: 112
        radius: 20
        color: Theme.surfaceContainer
        border {
            color: Theme.outlineVariant
            width: 1
        }
    }

    Row {
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 7
        }
        spacing: 6

        MediaSlider {
            width: 46
            height: parent.height
            value: Math.round(OsdConfig.sinkVolume)
            muted: OsdConfig.sinkMuted
            accentFill: Theme.inversePrimary
            accentOnFill: Theme.onPrimaryContainer
            trackFill: Theme.primaryColor
            icons: ["\uf026", "\uf027", "\uf027", "\uf028"]
            onScrub: d => OsdConfig.adjustVolume(d > 0 ? "2%+" : "2%-")
        }

        MediaSlider {
            id: brightSlider
            width: 46
            height: parent.height
            value: brightnessVal
            animate: ready
            accentFill: "red"
            accentOnFill: Theme.onPrimaryContainer
            trackFill: Theme.primaryColor
            icons: ["", "\udb80\udcde", "\udb80\udcdd", "\udb80\udce0"]
            onScrub: d => {
                brightnessVal = Math.max(0, Math.min(100, brightnessVal + d));
                OsdConfig.adjustBrightness(d > 0 ? "2%+" : "2%-");
            }

            property int brightnessVal: 0
            property bool ready: false

            Connections {
                target: OsdConfig
                function onBrightnessRead(value) {
                    brightSlider.brightnessVal = value;
                    brightSlider.ready = true;
                }
                function onCurrentValueChanged() {
                    if (OsdConfig.mode === "brightness")
                        brightSlider.brightnessVal = OsdConfig.currentValue;
                }
            }

            Component.onCompleted: OsdConfig.readBrightness()
        }
    }

    Row {
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        spacing: 6

        IconButton {
            active: !OsdConfig.sinkMuted
            activeColor: Theme.primaryColor
            inactiveColor: Theme.errorContainer
            activeIconColor: Theme.onPrimaryContainer
            inactiveIconColor: Theme.onErrorContainer
            icon: OsdConfig.sinkMuted ? "\uf026" : OsdConfig.sinkVolume >= 66 ? "\uf028" : OsdConfig.sinkVolume >= 33 ? "\uf027" : "\uf026"
            onClicked: OsdConfig.toggleMute()
        }

        IconButton {
            active: CommunicationConfig.hyprsunsetActive
            activeColor: Theme.primaryColor
            inactiveColor: Theme.surfaceContainer
            activeIconColor: Theme.onPrimaryContainer
            inactiveIconColor: Theme.onSurfaceVariant
            icon: "\ueeef"
            onClicked: CommunicationConfig.toggle()
        }
    }

    Item {
        anchors {
            left: parent.left
            right: parent.right
            rightMargin: 116 + 12
            top: parent.top
            bottom: parent.bottom
            bottomMargin: 54
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: _sliders.top
                bottomMargin: 6
            }
            radius: 20
            color: Theme.surfaceContainer
            border {
                color: Theme.outlineVariant
                width: 1
            }

            Uptime {
                anchors.fill: parent
            }
        }

        Column {
            id: _sliders
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            spacing: 6

            Row {
                width: parent.width
                height: 28
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "G"
                    font {
                        family: "CaskaydiaCove NF"
                        pixelSize: 14
                    }
                    color: Theme.onSurfaceVariant
                }

                M3Slider {
                    id: gammaSlider
                    width: parent.width - 22
                    height: parent.height
                    property real smoothVal: CommunicationConfig.gamma
                    value: smoothVal
                    Behavior on smoothVal {
                        NumberAnimation {
                            duration: 80
                            easing.type: Easing.OutCubic
                        }
                    }
                    Connections {
                        target: CommunicationConfig
                        function onGammaChanged() {
                            gammaSlider.smoothVal = CommunicationConfig.gamma;
                        }
                    }
                    minVal: CommunicationConfig.gammaMin
                    maxVal: CommunicationConfig.gammaMax
                    accentFill: Theme.primaryColor
                    trackFill: Theme.surfaceBright
                    onScrub: d => d > 0 ? CommunicationConfig.increaseGamma() : CommunicationConfig.decreaseGamma()
                }
            }

            Row {
                width: parent.width
                height: 28
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "T"
                    font {
                        family: "CaskaydiaCove NF"
                        pixelSize: 14
                    }
                    color: Theme.onSurfaceVariant
                }

                M3Slider {
                    id: tempSlider
                    width: parent.width - 22
                    height: parent.height
                    property real smoothVal: CommunicationConfig.temperature
                    value: smoothVal
                    Behavior on smoothVal {
                        NumberAnimation {
                            duration: 80
                            easing.type: Easing.OutCubic
                        }
                    }
                    Connections {
                        target: CommunicationConfig
                        function onTemperatureChanged() {
                            tempSlider.smoothVal = CommunicationConfig.temperature;
                        }
                    }
                    minVal: CommunicationConfig.tempMin
                    maxVal: CommunicationConfig.tempMax
                    accentFill: Theme.primaryColor
                    trackFill: Theme.surfaceBright
                    onScrub: d => d > 0 ? CommunicationConfig.increaseTemperature() : CommunicationConfig.decreaseTemperature()
                }
            }
        }
    }

    component IconButton: Item {
        width: 48
        height: 48
        required property bool active
        required property color activeColor
        required property color inactiveColor
        required property color activeIconColor
        required property color inactiveIconColor
        required property string icon
        signal clicked

        Rectangle {
            anchors.fill: parent
            border.width: 1
            radius: 14
            border.color: Theme.outlineVariant
            color: parent.active ? parent.activeColor : parent.inactiveColor
            Behavior on color {
                ColorBehavior {}
            }
        }

        Text {
            anchors.centerIn: parent
            text: parent.icon
            font {
                family: "CaskaydiaCove NF"
                pixelSize: 15
            }
            color: parent.active ? parent.activeIconColor : parent.inactiveIconColor
            Behavior on color {
                ColorBehavior {}
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component MediaSlider: Item {
        id: ms
        required property real value
        required property var icons
        property bool muted: false
        required property color accentFill
        required property color accentOnFill
        required property color trackFill
        property bool animate: true
        signal scrub(int delta)

        readonly property real fillFrac: muted ? 0 : value / 100
        readonly property string currentIcon: muted && icons[0] ? icons[0] : value >= 66 ? icons[3] : value >= 33 ? icons[2] : icons[1]

        ClippingRectangle {
            id: track
            anchors.fill: parent
            radius: 14
            color: Theme.surfaceContainer
            border {
                width: 1
                color: Theme.outlineVariant
            }

            Rectangle {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                height: track.height * ms.fillFrac
                color: ms.trackFill
                Behavior on height {
                    enabled: ms.animate
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: Math.min(track.height - 28, track.height - track.height * ms.fillFrac + 6)
                text: ms.currentIcon
                font {
                    family: "CaskaydiaCove NF"
                    pixelSize: 16
                }
                color: ms.fillFrac > 0.15 ? ms.accentOnFill : Theme.onSurfaceVariant
                Behavior on color {
                    ColorAnimation {
                        duration: 80
                    }
                }
                Behavior on y {
                    enabled: ms.animate
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                property real startY: 0
                property real startVal: 0

                onPressed: e => {
                    startY = e.y;
                    startVal = ms.value;
                }
                onPositionChanged: e => {
                    const delta = Math.round((startY - e.y) / ms.height * 100);
                    const newVal = Math.max(0, Math.min(100, Math.round(startVal + delta)));
                    if (newVal !== ms.value)
                        ms.scrub(newVal > ms.value ? 2 : -2);
                    if (newVal > 0 && newVal < 100) {
                        startY = e.y;
                        startVal = ms.value;
                    }
                }
                onWheel: w => {
                    const d = w.angleDelta.y || -w.angleDelta.x;
                    ms.scrub(d > 0 ? 2 : -2);
                }
            }
        }
    }
}
