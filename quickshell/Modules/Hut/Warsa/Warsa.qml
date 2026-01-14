/*
 https://git.safallama.com.np/ashborn/warsa [check here for the Warsa Module]
 */
import QtQuick
import Warsa
import qs.Services.Theme
import qs.Components.Icon

Item {
    id: root

    implicitWidth: calendarCard.width
    implicitHeight: calendarCard.height

    Warsa {
        id: calendar
        Component.onCompleted: {
            calendar.setToday();
        }
    }

    Warsa {
        id: todayReference
        Component.onCompleted: {
            setToday();
        }
    }

    Rectangle {
        id: calendarCard
        width: calendarContent.width + 28
        height: calendarContent.height + 28
        radius: 20
        color: Theme.surfaceContainer
        border.width: 1
        border.color: Theme.outlineVariant

        Column {
            id: calendarContent
            anchors.centerIn: parent
            spacing: 16

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: prevMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        font.pixelSize: 22
                        font.family: "CaskaydiaCove NF"
                        font.weight: Font.Light
                        color: Theme.onSurface
                        opacity: prevMouse.containsMouse ? 0.9 : 0.5

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                            }
                        }
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            calendar.previousMonth();
                        }
                    }
                }

                Text {
                    width: 180
                    text: calendar.monthName.charAt(0).toUpperCase() + calendar.monthName.slice(1) + " " + calendar.year
                    font.pixelSize: 14
                    font.family: "CaskaydiaCove NF"
                    font.weight: Font.Normal
                    color: Theme.onSurface
                    opacity: 0.85
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: nextMouse.containsMouse ? Theme.surfaceContainerHighest : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        font.pixelSize: 22
                        font.family: "CaskaydiaCove NF"
                        font.weight: Font.Light
                        color: Theme.onSurface
                        opacity: nextMouse.containsMouse ? 0.9 : 0.5

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                            }
                        }
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            calendar.nextMonth();
                        }
                    }
                }
            }

            Grid {
                width: 280
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                columnSpacing: 3
                rowSpacing: 3

                Repeater {
                    model: ["Ai", "So", "Ma", "Bu", "Bi", "Su", "Sa"]

                    Item {
                        width: 38
                        height: 26

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 10
                            font.family: "CaskaydiaCove NF"
                            font.weight: Font.Normal
                            color: Theme.onSurfaceVariant
                            opacity: 0.5
                        }
                    }
                }
            }

            Grid {
                width: 280
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                columnSpacing: 3
                rowSpacing: 3

                Repeater {
                    model: {
                        var days = calendar.getMonthDays(calendar.month);
                        var firstDay = calendar.getFirstDayOfMonth(calendar.month);
                        var result = [];

                        var isCurrentMonth = (calendar.month === todayReference.month && calendar.year === todayReference.year);

                        for (var i = 0; i < firstDay; i++) {
                            result.push({
                                day: 0,
                                isToday: false,
                                isSaturday: false
                            });
                        }

                        for (var j = 0; j < days.length; j++) {
                            var dayData = days[j];
                            dayData.isToday = isCurrentMonth && (dayData.day === todayReference.day);
                            result.push(dayData);
                        }

                        return result;
                    }

                    Rectangle {
                        width: 38
                        height: 38
                        radius: modelData.isToday ? 19 : 10

                        color: {
                            if (modelData.day === 0) {
                                return "transparent";
                            }
                            if (modelData.isToday) {
                                return Theme.primaryContainer;
                            }
                            if (dayMouse.containsMouse) {
                                return Theme.surfaceContainerHighest;
                            }
                            if (modelData.isSaturday) {
                                return Theme.surfaceContainerHigh;
                            }
                            return "transparent";
                        }

                        border.width: 0

                        Behavior on radius {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.day === 0 ? "" : modelData.day
                            font.pixelSize: 13
                            font.family: "CaskaydiaCove NF"
                            font.weight: modelData.isToday ? Font.Medium : Font.Normal
                            color: {
                                if (modelData.isToday) {
                                    return Theme.onPrimaryContainer;
                                }
                                if (modelData.isSaturday) {
                                    return Theme.errorColor;
                                }
                                return Theme.onSurface;
                            }
                            opacity: {
                                if (modelData.isToday) {
                                    return 1.0;
                                }
                                if (dayMouse.containsMouse) {
                                    return 0.9;
                                }
                                return 0.7;
                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 250
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 250
                                }
                            }
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            enabled: modelData.day !== 0
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                calendar.setDate(calendar.year, calendar.month, modelData.day);
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: 90
                height: 34
                radius: 17
                color: "transparent"
                border.width: 1
                border.color: todayMouse.containsMouse ? Theme.outlineColor : Theme.outlineVariant
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on border.color {
                    ColorAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Today"
                    font.pixelSize: 11
                    font.family: "CaskaydiaCove NF"
                    font.weight: Font.Normal
                    color: Theme.onSurface
                    opacity: todayMouse.containsMouse ? 0.85 : 0.55

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                        }
                    }
                }

                MouseArea {
                    id: todayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        calendar.setToday();
                    }
                }
            }
        }
    }
}
