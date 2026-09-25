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
    border.color: PanelColors.barBorder
    color: "transparent"

    readonly property var wifiDevice: {
        for (let i = 0; i < Networking.devices.values.length; i++) {
            const d = Networking.devices.values[i]
            if (d.type === DeviceType.Wifi) return d
        }
        return null
    }

    readonly property var activeNet: {
        if (!wifiDevice) return null
        for (let i = 0; i < wifiDevice.networks.values.length; i++) {
            const n = wifiDevice.networks.values[i]
            if (n.connected) return n
        }
        return null
    }

    readonly property bool isWifiConnected: activeNet !== null
    readonly property string wifiName: activeNet?.name ?? ""
    readonly property int wifiStrength: {
        if (!activeNet) return 0
        const s = activeNet.signalStrength
        return Math.round(s <= 1 ? s * 100 : s)
    }

    readonly property string normalStateLabelText: isWifiConnected ? `󱚻 :${root.wifiStrength}%` : "󰖪 :OFF"
    readonly property string hoverStateLabelText: isWifiConnected ? `󱚻 :${root.wifiName}` : "󰖪 :OFF"

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
