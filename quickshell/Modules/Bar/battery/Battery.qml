pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Modules.Bar.battery

Row {
    id: root
    spacing: 5
    Repeater {
        model: UPower.devices
        delegate: Row {
            required property UPowerDevice modelData
            visible: modelData.isLaptopBattery
            spacing: 5
            QtObject {
                id: batteryData
                property int perc: Math.round(modelData.percentage * 100)
                property bool isChargin: modelData.state === UPowerDeviceState.Charging

                property string displayText: isChargin ? "" : `${perc}%` //fancy seeing f0e7 not working
            }

            Pill {
                id: pill
                bWidth: 30
                bHeight: 18
                fillColor: "white"
                bgColor: "white"
                textColor: "black"
                fill: modelData.percentage
                onEntered: batteryPopup.toggle(true)
                onExited: {
                    batteryPopup.hovered = false;
                    batteryPopup.hideT.restart();
                }
                Text {
                    anchors.fill: parent
                    anchors.rightMargin: 3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: batteryData.displayText
                    font.pointSize: 8
                    font.bold: true
                    color: pill.textColor
                }
            }
        }
    }
}
