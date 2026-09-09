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
    color: "transparent"

    readonly property var isWifiConnected: Networking.devices.values[0].connected
    readonly property var wifiName: Networking.devices.values[0].networks.values.find(n => n.connected).name 
    readonly property var wifiStrength: Math.round(Networking.devices.values[0].networks.values.find(n => n.connected).signalStrength * 100)

    readonly property var normalStateLabelText: isWifiConnected ? `󱚻 :${root.wifiStrength}%` : "󰖪 :OFF"
    readonly property var hoverStateLabelText: isWifiConnected ? `󱚻 :${root.wifiName}` : "󰖪 :OFF"

    Text {
        id: label
        anchors.centerIn: parent
        font.family: FontConfig.fontFamily
        font.pixelSize: FontConfig.size
        color: "#d89868"
        text: root.normalStateLabelText
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: parent.opacity = 0.9, label.text = root.hoverStateLabelText
        onExited: parent.opacity = 1.0, label.text = root.normalStateLabelText
        onClicked: Quickshell.execDetached(["sh","-c","quickshell ipc call control openWifi"])
    }
}
