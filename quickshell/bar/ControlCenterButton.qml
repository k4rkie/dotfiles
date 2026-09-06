import QtQuick
import Quickshell
import "../theme"

Rectangle {
    id: root
    height: 26
    width: label.implicitWidth + 18
    color: "#0d0600"
    border.color: PanelColors.border
    border.width: 2
    radius: 0

    Text {
        id: label
        anchors.centerIn: parent
        text: "ctrl:󰢻"
        font.family: FontConfig.fontFamily
        font.pixelSize: 18
        color: "#e78a4e"
        rightPadding: 2
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: parent.opacity = 0.7
        onExited: parent.opacity = 1.0
        onClicked: Quickshell.execDetached(["sh", "-c", "quickshell ipc call control toggle"])
    }
}
