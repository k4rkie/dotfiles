import QtQuick
import ".."
import "../../theme"


Column {
    id: calendarPage
    required property var controlRoot
    visible: controlRoot.page === "calendar"
    width: parent ? parent.width : 460
    spacing: 8

    property alias dayGrid: calDayGrid
    property alias gridTrans: calGridTrans

    function updateMonth(delta) {
        controlRoot._calSelectedDay = -1
        if (delta > 0) { if (controlRoot._calViewMonth === 11) { controlRoot._calViewMonth = 0; controlRoot._calViewYear++ } else controlRoot._calViewMonth++ }
        else { if (controlRoot._calViewMonth === 0) { controlRoot._calViewMonth = 11; controlRoot._calViewYear-- } else controlRoot._calViewMonth-- }
    }

    // expose to controlRoot via Connections
    Connections {
        target: controlRoot
        function onCalUpdateMonthRequested(delta) { calendarPage.updateMonth(delta) }
    }

    Item {
        width: parent.width
        height: 28
        Rectangle {
            width: 28; height: 28; radius: 0
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            color: calPrevArea.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.15) : PanelColors.rowBackground
            border.width: 1; border.color: PanelColors.border
            Text { anchors.centerIn: parent; text: "󰁍"; font.pixelSize: FontConfig.sizeSmall; font.family: FontConfig.fontFamily; color: calPrevArea.containsMouse ? PanelColors.textAccent : PanelColors.textDim }
            MouseArea { id: calPrevArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: calendarPage.updateMonth(-1) }
        }
        Text {
            anchors.centerIn: parent
            text: controlRoot._calMonthName(controlRoot._calViewMonth) + " " + controlRoot._calViewYear
            font.pixelSize: FontConfig.size; font.bold: true; font.family: FontConfig.fontFamily; color: PanelColors.textAccent
            renderType: Text.NativeRendering
        }
        Rectangle {
            width: 28; height: 28; radius: 0
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            color: calNextArea.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.15) : PanelColors.rowBackground
            border.width: 1; border.color: PanelColors.border
            Text { anchors.centerIn: parent; text: "󰁔"; font.pixelSize: FontConfig.sizeSmall; font.family: FontConfig.fontFamily; color: calNextArea.containsMouse ? PanelColors.textAccent : PanelColors.textDim }
            MouseArea { id: calNextArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: calendarPage.updateMonth(1) }
        }
    }

    Row {
        width: parent.width
        Repeater {
            model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
            delegate: Text {
                width: parent.width / 7
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                font.pixelSize: FontConfig.sizeSmall; font.bold: true; font.family: FontConfig.fontFamily
                color: index >= 5 ? PanelColors.date : PanelColors.textDim
                renderType: Text.NativeRendering
            }
        }
    }
    Rectangle { width: parent.width; height: 2; color: PanelColors.border }

    Column {
        id: calDayGrid
        width: parent.width
        spacing: 2
        transform: Translate { id: calGridTrans; x: 0 }
        Repeater {
            model: Math.ceil((controlRoot._calFirstWeekday(controlRoot._calViewYear, controlRoot._calViewMonth) + controlRoot._calDaysInMonth(controlRoot._calViewYear, controlRoot._calViewMonth)) / 7)
            delegate: Rectangle {
                required property int index
                readonly property int weekIndex: index
                readonly property bool isCurrentWeek: {
                    var t = controlRoot._calTodayDay + controlRoot._calFirstWeekday(controlRoot._calTodayYear, controlRoot._calTodayMonth) - 1
                    return controlRoot._calViewMonth === controlRoot._calTodayMonth && controlRoot._calViewYear === controlRoot._calTodayYear && Math.floor(t/7) === weekIndex
                }
                width: parent.width; height: 32; radius: 0
                color: isCurrentWeek ? PanelColors.rowBackground : "transparent"
                Rectangle { visible: isCurrentWeek; width: 3; height: parent.height - 8; radius: 0; anchors { left: parent.left; verticalCenter: parent.verticalCenter } color: PanelColors.date }
                Row {
                    anchors.fill: parent
                    Repeater {
                        model: 7
                        delegate: Item {
                            required property int index
                            readonly property int cellIndex: weekIndex * 7 + index
                            readonly property int dayNum: cellIndex - controlRoot._calFirstWeekday(controlRoot._calViewYear, controlRoot._calViewMonth) + 1
                            readonly property bool isEmpty: dayNum < 1 || dayNum > controlRoot._calDaysInMonth(controlRoot._calViewYear, controlRoot._calViewMonth)
                            readonly property bool isToday: !isEmpty && dayNum === controlRoot._calTodayDay && controlRoot._calViewMonth === controlRoot._calTodayMonth && controlRoot._calViewYear === controlRoot._calTodayYear
                            readonly property bool isSelected: !isEmpty && dayNum === controlRoot._calSelectedDay
                            width: calDayGrid.width / 7; height: parent.height
                            Rectangle {
                                anchors.centerIn: parent; width: 30; height: 30; radius: 0
                                border.width: isToday || isSelected ? 1 : 0
                                border.color: isToday ? PanelColors.date : PanelColors.border
                                color: {
                                    if (isEmpty) return "transparent"
                                    let base = isToday ? PanelColors.date : (isSelected ? PanelColors.rowBackground : "transparent")
                                    if (calDayArea.containsMouse) { let h = isToday ? PanelColors.date : (isSelected ? PanelColors.rowBackground : PanelColors.rowBackground); return Qt.lighter(h, 1.15) }
                                    return base
                                }
                                Text { anchors.centerIn: parent; text: isEmpty ? "" : dayNum; font.pixelSize: FontConfig.sizeSmall; font.bold: isToday || isSelected; font.family: FontConfig.fontFamily; color: isToday ? PanelColors.pillForeground : (isSelected ? PanelColors.textAccent : PanelColors.textMain); renderType: Text.NativeRendering }
                            }
                            MouseArea { id: calDayArea; anchors.fill: parent; hoverEnabled: !isEmpty; cursorShape: !isEmpty ? Qt.PointingHandCursor : Qt.ArrowCursor; onClicked: if (!isEmpty) controlRoot._calSelectedDay = dayNum }
                        }
                    }
                }
            }
        }
    }
}
