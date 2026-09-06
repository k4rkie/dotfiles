import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    height: 26
    width: label.implicitWidth + 16
    color: "#080a03"
    border.color: PanelColors.border
    border.width: 2
    radius: 0

    property int percent: 0

    Process {
        id: memProc
        command: ["bash", "-c", "awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {if(t>0) printf \"%d\", (t-a)/t*100; else printf \"0\"}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseInt(text.trim())
                if (!isNaN(v)) root.percent = v
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: memProc.running = true
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: "mem:" + root.percent + "%"
        font.family: FontConfig.fontFamily
        font.pixelSize: 18
        color: "#a9b665"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: parent.opacity = 0.7
        onExited: parent.opacity = 1.0
        onClicked: Quickshell.execDetached(["foot", "-a", "btop", "btop"])
    }
}
