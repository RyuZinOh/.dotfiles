import QtQuick

Item {
    id: sliderRoot

    //public properties
    property real value: 0.5
    property bool isPressed: false
    property bool useVolumeCurve: false
    property bool dimmed: false

    // signals
    signal valueChangedByUser(real value)

    Rectangle {
        id: sliderTrack
        width: parent.width
        height: 4
        color: "black"
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: filledTrack
            radius: height / 2
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(4, sliderHandle.x + sliderHandle.width / 2)
            color: sliderRoot.dimmed ? "black" : "white"
            opacity: sliderRoot.dimmed ? 0.3 : 1.0

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        Rectangle {
            id: sliderHandle
            height: 14
            width: 14
            radius: 7
            color: "white"
            border.color: sliderRoot.dimmed ? "black" : "white"
            border.width: 2
            anchors.verticalCenter: parent.verticalCenter

            x: {
                let displayValue = sliderRoot.value;
                if (sliderRoot.useVolumeCurve) {
                    displayValue = Math.pow(displayValue, 1.5);
                }
                return Math.max(0, Math.min(displayValue * (sliderTrack.width - width), sliderTrack.width - width));
            }

            opacity: sliderRoot.dimmed ? 0.4 : 1.0

            Behavior on x {
                enabled: !sliderRoot.isPressed
                NumberAnimation {
                    duration: 80
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        // cursorShape: Qt.PointingHandCursor

        onEntered: {
            sliderHandle.height = 18;
            sliderHandle.width = 18;
        }

        onExited: {
            if (!sliderRoot.isPressed) {
                sliderHandle.height = 14;
                sliderHandle.width = 14;
            }
        }

        onPressed: function (mouse) {
            sliderRoot.isPressed = true;
            sliderHandle.height = 18;
            sliderHandle.width = 18;
            updateValue(mouse.x);
        }

        onPositionChanged: function (mouse) {
            if (sliderRoot.isPressed) {
                updateValue(mouse.x);
            }
        }

        onReleased: {
            sliderRoot.isPressed = false;
            sliderHandle.height = 14;
            sliderHandle.width = 14;
        }

        function updateValue(mouseX) {
            let rawValue = Math.max(0, Math.min(mouseX / sliderTrack.width, 1));

            if (sliderRoot.useVolumeCurve) {
                sliderRoot.value = Math.pow(rawValue, 0.666667);
            } else {
                sliderRoot.value = rawValue;
            }

            sliderRoot.valueChangedByUser(sliderRoot.value);
        }
    }
}
