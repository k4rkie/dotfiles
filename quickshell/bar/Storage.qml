import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    height: 30
    width: label.implicitWidth + 16
    color: "#080a03"
    border.color: PanelColors.border
    border.width: 2
    radius: 0

    property var storageUsed: ""

    Process {
        id: storgProc
        command: ["bash", "-c", "df -h / | awk 'NR==2 {print $3}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.storageUsed = text.trim()
            }
        }
    }

    Timer {
        interval: 3600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: storgProc.running = true
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: " :" + root.storageUsed
        font.family: FontConfig.fontFamily
        font.pixelSize: FontConfig.size
        color: "#2A9C52"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: parent.opacity = 0.8
        onExited: parent.opacity = 1.0
    }
}
