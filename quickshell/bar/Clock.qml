import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    height: 30
    width: label.implicitWidth + 16
    color: "#02040a"
    border.color: PanelColors.border
    border.width: 2
    radius: 0

    property string timeText: ""

    function updateTime() {
        timeText = Qt.formatDateTime(new Date(), " hh:mm AP")
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateTime()
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.timeText
        font.family: FontConfig.fontFamily
        font.pixelSize: FontConfig.size
        color: "#5c6bc0"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: parent.opacity = 0.7
        onExited: parent.opacity = 1.0
        onClicked: {
            try { BarAnchor.setAnchor(root, "control") } catch(e) { console.log("anchor fail", e) }
            BarAnchor.toggleControl()
        }
    }
}
