import QtQuick
import Quickshell
import Quickshell.Networking
import "../theme"

Rectangle {
    id: root
    height: 30
    width: label.implicitWidth + 16
    radius: 0
    border.width: 2
    border.color: PanelColors.border
    color: "#060400"

    Text {
        id: label
        anchors.centerIn: parent
        font.family: FontConfig.fontFamily
        font.pixelSize: FontConfig.size
        color: "#e78a4e"
        text: {
            return "󱚻" + " :" +"ON"
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: parent.opacity = 0.7
        onExited: parent.opacity = 1.0
        onClicked: Quickshell.execDetached(["sh","-c","quickshell ipc call control openWifi"])
    }
}
