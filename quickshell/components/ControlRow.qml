import QtQuick

Column {
    id: controlRoot
    spacing: 6

    //properties
    property string iconText: ""
    property string iconFamily: "CaskaydiaCove NF"
    property string labelText: ""
    property string valueText: ""
    property real sliderValue: 0.5
    property bool isDimmed: false
    property bool useVolumeCurve: false
    property bool showIconAnimation: false
    property bool iconClickable: false
    property alias sliderControl: sliderControl

    // signals
    signal sliderValueChangedByUser(real value)
    signal iconClicked

    // Label + Value
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 8

        Text {
            text: controlRoot.labelText
            color: "white"
            font.pointSize: 9
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: controlRoot.valueText
            color: controlRoot.isDimmed ? "black" : "white"
            font.pointSize: 9
            font.weight: Font.DemiBold
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }
    }

    // Icon + Slider
    Row {
        spacing: 12
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: controlIcon
            text: controlRoot.iconText
            color: controlRoot.isDimmed ? "black" : "white"
            font.pointSize: 16
            font.family: controlRoot.iconFamily
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.9

            property real targetRotation: 0
            property real lastValue: sliderControl.value

            rotation: targetRotation

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Behavior on rotation {
                enabled: controlRoot.showIconAnimation && sliderControl.isPressed
                RotationAnimation {
                    duration: 150
                    direction: controlIcon.targetRotation > controlIcon.rotation ? RotationAnimation.Clockwise : RotationAnimation.Counterclockwise
                }
            }

            Connections {
                target: sliderControl
                enabled: controlRoot.showIconAnimation
                function onValueChanged() {
                    if (sliderControl.isPressed) {
                        let delta = sliderControl.value - controlIcon.lastValue;
                        controlIcon.targetRotation += delta * 360;
                        controlIcon.lastValue = sliderControl.value;
                    }
                }
            }

            // MouseArea {
            //     anchors.fill: parent
            //     anchors.margins: -4
            //     enabled: controlRoot.iconClickable
            //     // cursorShape: controlRoot.iconClickable ? Qt.PointingHandCursor : Qt.ArrowCursor
            //     onClicked: controlRoot.iconClicked()
            // }
        }

        //slider
        SliderControl {
            id: sliderControl
            width: 160
            height: 28
            value: controlRoot.sliderValue
            useVolumeCurve: controlRoot.useVolumeCurve
            dimmed: controlRoot.isDimmed

            onValueChangedByUser: function (newValue) {
                controlRoot.sliderValueChangedByUser(newValue);
            }
        }
    }
}
