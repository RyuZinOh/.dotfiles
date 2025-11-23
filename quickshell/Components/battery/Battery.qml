pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.UPower

Row {
    id: root
    spacing: 5

    Repeater {
        model: UPower.devices
        delegate: Item {
            required property UPowerDevice modelData
            visible: modelData.isLaptopBattery
            width: batteryContainer.width
            height: batteryContainer.height

            QtObject {
                id: batteryData
                property real percentage: modelData.percentage
                property int percentInt: Math.round(percentage * 100)
                property int state: modelData.state
                property bool isCharging: state === UPowerDeviceState.Charging
                property bool isDischarging: state === UPowerDeviceState.Discharging
                property bool isFullyCharged: state === UPowerDeviceState.FullyCharged

                property color accentColor: {
                    if (isCharging || isFullyCharged) {
                        return "#00ff00";
                    }
                    if (percentInt <= 10) {
                        return "#ff0000";
                    }
                    if (percentInt <= 20) {
                        return "#f99000";
                    }
                    return "#ffffff";
                }

                property string displayText: isCharging ? "󱐋" : `${percentInt}%`
            }

            Item {
                id: batteryContainer
                width: 42
                height: 22

                Rectangle {
                    id: terminal
                    width: 3
                    height: 10
                    radius: 2
                    color: batteryData.accentColor
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: batteryBody
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 38
                    height: 20
                    radius: 4
                    color: "transparent"
                    border.color: batteryData.accentColor
                    border.width: 1.5

                    Rectangle {
                        id: fillBar
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 2
                        width: Math.max(0, (parent.width - 4) * batteryData.percentage)
                        radius: 2
                        color: batteryData.accentColor

                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 300
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: batteryData.displayText
                        font.family: "0xProto Nerd Font"
                        font.pixelSize: batteryData.isCharging ? 14 : 9
                        font.bold: true
                        color: batteryData.percentage > 0.5 ? "#000000" : batteryData.accentColor

                        SequentialAnimation on opacity {
                            running: batteryData.isCharging
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0.3
                                duration: 800
                                easing.type: Easing.InOutSine
                            }
                            NumberAnimation {
                                to: 1.0
                                duration: 800
                                easing.type: Easing.InOutSine
                            }
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }
    }
}
