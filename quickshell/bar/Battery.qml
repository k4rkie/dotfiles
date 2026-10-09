import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../theme"

Rectangle {
    id: root
    height: 30
    width: row.implicitWidth + 16
    radius: 0
    border.width: 2
    border.color: PanelColors.barBorder

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

    color: "transparent"

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
    readonly property color iconColor: {
        if (root.isCritical) return "#d87a78"
        if (root.isWarning) return "#d89868"
        return "#8ba5a0"
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 20

            Text {
                anchors.centerIn: parent
                text: root.batIcon
                font.family: FontConfig.fontFamily
                font.pixelSize: FontConfig.size
                color: root.iconColor
            }

            Text {
                anchors.centerIn: parent
                rotation: 90
                transformOrigin: Item.Center
                visible: root.isPlugged && root.isReady
                text: "󱐋"
                font.family: FontConfig.fontFamily
                font.pixelSize: 15
                color: "#080610"
                style: Text.Outline
                styleColor: "#8ba5a0"
            }
        }

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            font.family: FontConfig.fontFamily
            font.pixelSize: FontConfig.size
            color: root.iconColor
            text: !root.isReady ? ":--%" : ":" + root.percent + "%"
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: parent.opacity = 0.7
        onExited: parent.opacity = 1.0
    }
}
