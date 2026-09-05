import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: root
    color: "transparent"

    property color borderColor: PanelColors.date
    property int padding: 12
    property bool clipContent: false

    // fullscreen so clicks outside the card can dismiss it
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; left: true; right: true; bottom: true }
    // card sits 8px above the waybar (18), centered horizontally
    readonly property int bottomBarGap: 40

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Shortcut {
        sequence: "Escape"
        onActivated: root.toggle()
    }

    visible: animState !== "closed"

    property string animState: "closed"

    property int contentHeight: contentCol.implicitHeight

    property real slideOffset: 0

    function toggle() {
        if (animState === "closed" || animState === "closing") {
            var now = new Date()
            _todayDay = now.getDate()
            _todayMonth = now.getMonth()
            _todayYear = now.getFullYear()
            _selectedDay = -1
            _viewYear = _todayYear
            _viewMonth = _todayMonth
            animState = "open"
            closeAnim.stop()
            openAnim.restart()
        } else {
            animState = "closing"
            openAnim.stop()
            closeAnim.restart()
        }
    }

    SequentialAnimation {
        id: openAnim
        ScriptAction { script: { root.slideOffset = root.height + 8; innerRect.opacity = 0 } }
        ParallelAnimation {
            NumberAnimation { target: root; property: "slideOffset"; to: 0; duration: 0; easing.type: Easing.OutExpo }
            NumberAnimation { target: innerRect; property: "opacity"; to: 1; duration: 0; easing.type: Easing.OutQuad }
        }
    }

    SequentialAnimation {
        id: closeAnim
        ParallelAnimation {
            NumberAnimation { target: root; property: "slideOffset"; to: root.height + 8; duration: 0; easing.type: Easing.InQuad }
            NumberAnimation { target: innerRect; property: "opacity"; to: 0; duration: 0; easing.type: Easing.InQuad }
        }
        ScriptAction { script: { root.animState = "closed"; root.slideOffset = 0; innerRect.opacity = 1 } }
    }

    IpcHandler {
        target: "calendar"
        function toggle(): void {
            root.toggle()
        }
    }

    property int _viewYear: new Date().getFullYear()
    property int _viewMonth: new Date().getMonth()
    property int _selectedDay: -1

    property int _todayDay: new Date().getDate()
    property int _todayMonth: new Date().getMonth()
    property int _todayYear: new Date().getFullYear()

    function updateMonth(delta) {
        monthAnim.direction = delta
        monthAnim.restart()
    }

    SequentialAnimation {
        id: monthAnim
        property int direction: 0
        ParallelAnimation {
            NumberAnimation { target: dayGrid; property: "opacity"; to: 0; duration: 0; easing.type: Easing.OutCubic }
            NumberAnimation { target: gridTrans; property: "x"; to: monthAnim.direction > 0 ? -30 : 30; duration: 0; easing.type: Easing.OutCubic }
        }
        ScriptAction {
            script: {
                root._selectedDay = -1
                if (monthAnim.direction > 0) {
                    if (root._viewMonth === 11) { root._viewMonth = 0; root._viewYear++ }
                    else root._viewMonth++
                } else {
                    if (root._viewMonth === 0) { root._viewMonth = 11; root._viewYear-- }
                    else root._viewMonth--
                }
            }
        }
        PropertyAction { target: gridTrans; property: "x"; value: monthAnim.direction > 0 ? 30 : -30 }
        ParallelAnimation {
            NumberAnimation { target: dayGrid; property: "opacity"; to: 1; duration: 0; easing.type: Easing.OutExpo }
            NumberAnimation { target: gridTrans; property: "x"; to: 0; duration: 0; easing.type: Easing.OutExpo }
        }
    }

    function _monthName(m) {
        return ["January","February","March","April","May","June",
                "July","August","September","October","November","December"][m]
    }
    function _daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }
    function _firstWeekday(y, m) { return (new Date(y, m, 1).getDay() + 6) % 7 }

    // click outside the card closes the menu
    MouseArea {
        anchors.fill: parent
        enabled: root.animState === "open"
        onClicked: root.toggle()
    }

     // flat: no bevel — kept as no-op for compatibility
     component BevelOverlay: Item {
         property bool pressed: false
         anchors.fill: parent
         z: 1
     }

     Rectangle {
        id: innerRect
        width: 240
        height: root.contentHeight + (root.padding * 2)
        x: (parent.width - width) / 2 + 750
        y: root.height - height - root.bottomBarGap + root.slideOffset
        radius: 0
        color: PanelColors.popupBackground
        Behavior on color { ColorAnimation { duration: 0 } }
        border.color: PanelColors.border
        Behavior on border.color { ColorAnimation { duration: 0 } }
        border.width: 1
        clip: root.clipContent

         // swallow clicks so they don't reach the outside catcher
         MouseArea { anchors.fill: parent; onPressed: (m) => m.accepted = true }

         HoverHandler { id: hover }

        Column {
            id: contentCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: root.padding }
            spacing: 6

            Item {
                width: parent.width
                height: 28

                Rectangle {
                    id: prevBtn
                    width: 24; height: 24; radius: 0
                     anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                     color: prevArea.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.15) : PanelColors.rowBackground
                     border.width: 1
                     border.color: PanelColors.border
                      Behavior on color { ColorAnimation { duration: 0 } }
                    Text {
                    renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.pixelSize: 16; font.family: FontConfig.fontFamily
                        color: prevArea.containsMouse ? PanelColors.textAccent : PanelColors.textDim
                        Behavior on color { ColorAnimation { duration: 0 } }
                    }
                     MouseArea {
                         id: prevArea; z: 2; anchors.fill: parent; hoverEnabled: true
                        onClicked: root.updateMonth(-1)
                    }
                }

                Text {
                renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: root._monthName(root._viewMonth) + " " + root._viewYear
                    font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                    color: PanelColors.textAccent
                }

                Rectangle {
                    id: nextBtn
                    width: 24; height: 24; radius: 0
                     anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                     color: nextArea.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.15) : PanelColors.rowBackground
                     border.width: 1
                     border.color: PanelColors.border
                      Behavior on color { ColorAnimation { duration: 0 } }
                    Text {
                    renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: "󰁔"
                        font.pixelSize: 16; font.family: FontConfig.fontFamily
                        color: nextArea.containsMouse ? PanelColors.textAccent : PanelColors.textDim
                        Behavior on color { ColorAnimation { duration: 0 } }
                    }
                     MouseArea {
                         id: nextArea; z: 2; anchors.fill: parent; hoverEnabled: true
                        onClicked: root.updateMonth(1)
                    }
                }
            }

            Row {
                width: parent.width
                Repeater {
                    model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
                    delegate: Text {
                        width: contentCol.width / 7
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                        color: index >= 5 ? PanelColors.date : PanelColors.textDim
                    }
                }
            }

            Rectangle {
                width: parent.width; height: 2
                color: PanelColors.border
            }

            Column {
                id: dayGrid
                width: parent.width
                spacing: 2
                transform: Translate { id: gridTrans; x: 0 }

                Repeater {
                    model: Math.ceil((_firstWeekday(root._viewYear, root._viewMonth)
                            + _daysInMonth(root._viewYear, root._viewMonth)) / 7)

                    delegate: Rectangle {
                        required property int index
                        readonly property int weekIndex: index

                        readonly property bool isCurrentWeek: {
                            var todayTotal = root._todayDay + _firstWeekday(root._todayYear, root._todayMonth) - 1
                            return root._viewMonth === root._todayMonth
                                && root._viewYear  === root._todayYear
                                && Math.floor(todayTotal / 7) === weekIndex
                        }

                        width: parent.width
                        height: 28
                        radius: 0
                        color: isCurrentWeek ? PanelColors.rowBackground : "transparent"

                        Rectangle {
                            visible: isCurrentWeek
                            width: 3; height: parent.height - 10; radius: 0
                            anchors { left: parent.left; leftMargin: 0; verticalCenter: parent.verticalCenter }
                            color: PanelColors.date
                        }

                        Row {
                            anchors.fill: parent

                            Repeater {
                                model: 7
                                delegate: Item {
                                    required property int index
                                    readonly property int cellIndex: weekIndex * 7 + index
                                    readonly property int dayNum: cellIndex - _firstWeekday(root._viewYear, root._viewMonth) + 1
                                    readonly property bool isEmpty: dayNum < 1 || dayNum > _daysInMonth(root._viewYear, root._viewMonth)
                                    readonly property bool isToday: !isEmpty
                                                                    && dayNum === root._todayDay
                                                                    && root._viewMonth === root._todayMonth
                                                                    && root._viewYear  === root._todayYear
                                    readonly property bool isSelected: !isEmpty && dayNum === root._selectedDay

                                    width: contentCol.width / 7
                                    height: parent.height

                                     Rectangle {
                                        anchors.centerIn: parent
                                        width: 24; height: 24; radius: 0
                                        border.width: isToday || isSelected ? 1 : 0
                                        border.color: isToday ? PanelColors.date : PanelColors.border
                                        color: {
                                            if (isEmpty) return "transparent"
                                            let base = isToday ? PanelColors.date : (isSelected ? PanelColors.rowBackground : "transparent")
                                            if (dayArea.containsMouse) {
                                                let hoverRef = isToday ? PanelColors.date : (isSelected ? PanelColors.rowBackground : PanelColors.rowBackground)
                                                return Qt.lighter(hoverRef, 1.15)
                                            }
                                            return base
                                         }

                                          Behavior on color { ColorAnimation { duration: 0 } }

                                        Text {
                                        renderType: Text.NativeRendering
                                            anchors.centerIn: parent
                                            text: isEmpty ? "" : dayNum
                                            font.pixelSize: 16; font.bold: isToday || isSelected; font.family: FontConfig.fontFamily
                                            color: isToday ? PanelColors.pillForeground : (isSelected ? PanelColors.textAccent : PanelColors.textMain)
                                            Behavior on color { ColorAnimation { duration: 0 } }
                                        }
                                    }

                                     MouseArea {
                                         id: dayArea
                                         z: 2
                                        anchors.fill: parent
                                        hoverEnabled: !isEmpty
                                        cursorShape: !isEmpty ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if (!isEmpty) root._selectedDay = dayNum
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
