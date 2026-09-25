import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    height: 30
    width: label.implicitWidth + 16
    color: "transparent"
    border.color: PanelColors.barBorder
    border.width: 2
    radius: 0

    property string timeText: ""
    property var distroLogos: {
      "nixos" :"󱄅",
      "fedora":"",
      "arch"  :"󰣇",
      "void"  :"",
      "debian":"󰣚",
      "gentoo":"󰣨"
    }
    property string distro: ""

    Process {
        id: getDistroLogo
        command: ["bash", "-c", "source /etc/os-release && echo $ID"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.distro = this.text.trim()
                root.updateTime()
            }
        }
    }

    function updateTime() {
        timeText = Qt.formatDateTime(new Date(), `${distroLogos[distro] || ''} hh:mm AP`)
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
        color: "#aaaaaa"
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
