pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Widgets

Row {
    id: root
    spacing: 5
    Repeater {
        model: UPower.devices
        delegate: Row {
            required property UPowerDevice modelData
            property real percentage: modelData.percentage
            visible: modelData.isLaptopBattery

            readonly property string batIconPath: {
                if (modelData.state === UPowerDevice.FullyCharged || modelData.state === "fully-charged") {
                    return "../../../assets/svg_qml/full.qml"; // full
                }
                if (modelData.state === UPowerDevice.Charging || modelData.state === "charging") {
                    return "../../../assets/svg_qml/charging.qml"; // charging
                }
                if (percentage >= 1.00) {
                    return "../../../assets/svg_qml/full.qml"; // full
                }
                if (percentage >= 0.80) {
                    return "../../../assets/svg_qml/80_across.qml"; // over 80
                }
                if (percentage >= 0.65) {
                    return "../../../svg_qml/65_accross.qml"; // over 65
                }
                if (percentage >= 0.45) {
                    return "../../../assets/svg_qml/45_accross.qml"; // over 45
                }
                if (percentage >= 0.30) {
                    return "../../../assets/svg_qml/30_approx.qml"; // 30 approx
                }
                if (percentage >= 0.20) {
                    return "../../../assets/svg_qml/20_approx.qml"; // 20 approx
                }

                return "../../../assets/svg_qml/below_10.qml"; // below ten
            }

            Loader {
                source: parent.batIconPath
                width: 26
                height: 26
            }
            Text {
                font.pointSize: 12
                font.family: "0xProto Nerd Font"
                color: "white"
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                text: (parent.percentage * 100).toFixed(0) + "%"
            }
        }
    }
}
