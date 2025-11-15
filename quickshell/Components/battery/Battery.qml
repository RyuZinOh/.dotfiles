pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Row {
    id: root
    spacing: 5

    Repeater {
        model: UPower.devices
        delegate: Item {
            required property UPowerDevice modelData
            visible: modelData.isLaptopBattery
            width: batteryRow.width
            height: batteryRow.height

            QtObject {
                id: batteryData
                property real percentage: modelData.percentage
                property int percentInt: Math.round(percentage * 100)
                property int state: modelData.state
                property bool isCharging: state === UPowerDeviceState.Charging
                property bool isDischarging: state === UPowerDeviceState.Discharging
                property bool isFullyCharged: state === UPowerDeviceState.FullyCharged

                property color fillColor: {
                    if (isCharging) {
                        return "green";
                    }
                    if (percentInt <= 10) {
                        return "red";
                    }
                    if (percentInt <= 20) {
                        return "orange";
                    }
                    return "white";
                }
                property string displayText: isCharging ? "󱐋" : `${percentInt}%`//fancy seeing f0e7 not working
            }

            Row {
                id: batteryRow
                spacing: 5

                Item {
                    width: pill.width
                    height: pill.height

                    Pill {
                        id: pill
                        bWidth: 35
                        bHeight: 20
                        fillColor: batteryData.fillColor
                        emptyColor: "black"
                        borderColor: batteryData.fillColor
                        textColor: "black"
                        fill: batteryData.percentage
                        borderWidth: 2
                        terminalWidth: 3
                        terminalHeight: 8
                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -2
                        text: batteryData.displayText
                        font.family: "0xProto Nerd Font"
                        font.pixelSize: batteryData.isCharging ? 16 : 10
                        font.bold: true
                        color: "black"

                        SequentialAnimation on opacity {
                            running: batteryData.isCharging
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0.3
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                to: 1.0
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
            }
        }
    }
}
