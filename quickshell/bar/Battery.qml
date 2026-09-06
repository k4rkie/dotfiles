import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../theme"

Rectangle {
    id: root
    height: 30
    width: label.implicitWidth + 16
    radius: 0
    border.width: 2
    border.color: PanelColors.border

    readonly property var battery: {
        if (UPower.displayDevice && UPower.displayDevice.ready && UPower.displayDevice.isLaptopBattery)
            return UPower.displayDevice
        for (let i = 0; i < UPower.devices.values.length; i++) {
            const d = UPower.devices.values[i]
            if (d.isLaptopBattery && d.ready) return d
        }
        return UPower.displayDevice
    }
    readonly property bool isReady: battery && battery.ready
    readonly property int percent: {
        if (!isReady) return 0
        const p = battery.percentage
        return Math.round(p <= 1.0 ? p * 100 : p)
    }
    readonly property bool isCharging: isReady ? battery.state === UPowerDeviceState.Charging : false
    readonly property bool isPlugged: isCharging || (isReady ? battery.state === UPowerDeviceState.FullyCharged : false)
    readonly property bool isWarning: percent <= 30 && percent > 15 && !isPlugged
    readonly property bool isCritical: percent <= 15 && !isPlugged

    color: {
        if (isCritical) return "#0d0200"
        if (isWarning) return "#0d0600"
        return "#040806"
    }

    readonly property var icons: ["", "", "", "", ""]
    readonly property string batIcon: {
        if (!isReady) return ""
        var idx = Math.floor(percent / 20)
        if (percent >= 100) idx = 4
        else if (percent >= 80) idx = 4
        else if (percent >= 60) idx = 3
        else if (percent >= 40) idx = 2
        else if (percent >= 20) idx = 1
        else idx = 0
        return icons[idx]
    }

    Text {
        id: label
        anchors.centerIn: parent
        font.family: FontConfig.fontFamily
        font.pixelSize: FontConfig.size
        color: {
            if (root.isCritical) return "#ea6962"
            if (root.isWarning) return "#e78a4e"
            return "#7daea3"
        }
        text: {
            if (!root.isReady) return " :--%"
            if (root.isPlugged) return batIcon + " 󱐋:" + root.percent + "%"
            return batIcon + " :" + root.percent + "%"
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: parent.opacity = 0.7
        onExited: parent.opacity = 1.0
    }
}
