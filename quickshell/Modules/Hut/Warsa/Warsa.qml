/*
 https://git.safallama.com.np/ashborn/warsa [check here for the Warsa Module]
 https://git.safallama.com.np/ashborn/kraken [check here for the Kraken Module]
 */
pragma ComponentBehavior: Bound
import QtQuick
import Warsa
import Kraken
import qs.Services.Theme

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
    Kraken {
        id: eventsAdapter
        filePath: "/home/safal726/.cache/safalQuick/warsa.json"
    }
    function getEventForDate(month, day) {
        var key = month + "-" + day;
        return eventsAdapter.get(key, null);
    }
    Rectangle {
        id: eventPopup
        visible: false
        width: 220
        height: popupText.height + 16
        radius: 16
        color: Theme.surfaceContainerHighest
        border.width: 0
        z: 1000
        opacity: 0
        property string title: ""
        property string description: ""
        Text {
            id: popupText
            anchors.centerIn: parent
            width: 200
            textFormat: Text.StyledText
            text: eventPopup.title + " -> " + eventPopup.description
            font.pixelSize: 11
            font.family: "CaskaydiaCove NF"
            font.weight: Font.Medium
            color: Theme.onSurface
            wrapMode: Text.WordWrap
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
    Rectangle {
        id: calendarCard
        width: calendarContent.width + 32
        height: calendarContent.height + 32
        radius: 28
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
                    width: 40
                    height: 40
                    radius: 20
                    color: prevMouse.containsMouse ? Theme.primaryContainer : Theme.surfaceContainerHigh
                    border.width: 0
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "<"
                        font.pixelSize: 20
                        font.family: "CaskaydiaCove NF"
                        font.weight: Font.Light
                        color: prevMouse.containsMouse ? Theme.onPrimaryContainer : Theme.onSurface
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
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
                    font.weight: Font.Medium
                    color: Theme.onSurface
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: nextMouse.containsMouse ? Theme.primaryContainer : Theme.surfaceContainerHigh
                    border.width: 0
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: ">"
                        font.pixelSize: 20
                        font.family: "CaskaydiaCove NF"
                        font.weight: Font.Light
                        color: nextMouse.containsMouse ? Theme.onPrimaryContainer : Theme.onSurface
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
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
                    delegate: Item {
                        id: dayHeaderItem
                        required property string modelData
                        required property int index

                        width: 38
                        height: 24
                        Text {
                            anchors.centerIn: parent
                            text: dayHeaderItem.modelData
                            font.pixelSize: 9
                            font.family: "CaskaydiaCove NF"
                            font.weight: Font.Medium
                            color: Theme.onSurfaceVariant
                            opacity: 0.6
                        }
                    }
                }
            }
            Grid {
                id: daysGrid
                width: 280
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                columnSpacing: 3
                rowSpacing: 3
                property var cachedModel: []
                function updateModel() {
                    var days = calendar.getMonthDays(calendar.month);
                    var firstDay = calendar.getFirstDayOfMonth(calendar.month);
                    var result = [];
                    for (var i = 0; i < firstDay; i++) {
                        result.push({
                            day: 0,
                            isToday: false,
                            isSaturday: false,
                            hasEvent: false
                        });
                    }
                    for (var j = 0; j < days.length; j++) {
                        var dayData = days[j];
                        var event = root.getEventForDate(calendar.month, dayData.day);
                        dayData.hasEvent = event !== null;
                        dayData.eventData = event;
                        result.push(dayData);
                    }
                    daysGrid.cachedModel = result;
                }
                Connections {
                    target: calendar
                    function onMonthChanged() {
                        daysGrid.updateModel();
                    }
                }
                Connections {
                    target: eventsAdapter
                    function onDataLoaded() {
                        daysGrid.updateModel();
                    }
                }
                Component.onCompleted: {
                    daysGrid.updateModel();
                }
                Repeater {
                    model: daysGrid.cachedModel
                    delegate: Rectangle {
                        id: dayRect
                        required property var modelData
                        required property int index

                        width: 38
                        height: 38
                        radius: dayMouse.containsMouse ? 19 : 10
                        color: {
                            if (dayRect.modelData.day === 0) {
                                return "transparent";
                            }
                            if (dayRect.modelData.isToday) {
                                return Theme.primaryContainer;
                            }
                            if (dayMouse.containsMouse) {
                                return Theme.secondaryContainer;
                            }
                            if (dayRect.modelData.hasEvent) {
                                return Theme.tertiaryContainer;
                            }
                            if (dayRect.modelData.isSaturday) {
                                return Theme.errorContainer;
                            }
                            return Theme.surfaceContainerHigh;
                        }
                        border.width: 0
                        Behavior on radius {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                        Rectangle {
                            width: 4
                            height: 4
                            radius: 2
                            color: Theme.primaryColor
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            visible: dayRect.modelData.hasEvent && !dayRect.modelData.isToday
                            opacity: 0.8
                        }
                        Text {
                            anchors.centerIn: parent
                            text: dayRect.modelData.day === 0 ? "" : dayRect.modelData.day
                            font.pixelSize: 12
                            font.family: "CaskaydiaCove NF"
                            font.weight: dayRect.modelData.isToday ? Font.Medium : Font.Normal
                            color: {
                                if (dayRect.modelData.isToday) {
                                    return Theme.onPrimaryContainer;
                                }
                                if (dayMouse.containsMouse) {
                                    return Theme.onSecondaryContainer;
                                }
                                if (dayRect.modelData.hasEvent) {
                                    return Theme.onTertiaryContainer;
                                }
                                if (dayRect.modelData.isSaturday) {
                                    return Theme.onErrorContainer;
                                }
                                return Theme.onSurface;
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }
                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            enabled: dayRect.modelData.day !== 0
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                calendar.setDate(calendar.year, calendar.month, dayRect.modelData.day);
                            }
                            onEntered: {
                                if (dayRect.modelData.hasEvent && dayRect.modelData.eventData) {
                                    eventPopup.title = dayRect.modelData.eventData.title || "Event";
                                    eventPopup.description = dayRect.modelData.eventData.description || "";
                                    var pos = dayMouse.mapToItem(root, 0, 0);
                                    eventPopup.x = pos.x + (dayMouse.width - eventPopup.width) / 2;
                                    eventPopup.y = pos.y - eventPopup.height - 8;
                                    if (eventPopup.x < 0) {
                                        eventPopup.x = 8;
                                    }
                                    if (eventPopup.x + eventPopup.width > root.width) {
                                        eventPopup.x = root.width - eventPopup.width - 8;
                                    }
                                    if (eventPopup.y < 0) {
                                        eventPopup.y = pos.y + dayMouse.height + 8;
                                    }
                                    eventPopup.visible = true;
                                    eventPopup.opacity = 1;
                                }
                            }
                            onExited: {
                                eventPopup.visible = false;
                                eventPopup.opacity = 0;
                            }
                        }
                    }
                }
            }
            Rectangle {
                width: 90
                height: 36
                radius: 18
                color: todayMouse.containsMouse ? Theme.primaryContainer : Theme.surfaceContainerHigh
                border.width: 0
                anchors.horizontalCenter: parent.horizontalCenter
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: "Today"
                    font.pixelSize: 11
                    font.family: "CaskaydiaCove NF"
                    font.weight: Font.Normal
                    color: todayMouse.containsMouse ? Theme.onPrimaryContainer : Theme.onSurface
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
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
