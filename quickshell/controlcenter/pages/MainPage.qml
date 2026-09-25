import QtQuick
import ".."
import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth
import "../../theme"
import "../components"


Column {
    id: mainPage
    required property var controlRoot
    visible: controlRoot.page === "main"
    width: parent ? parent.width : 460
    spacing: 14

    Row {
        spacing: 8
        width: parent.width

        Pill {
            width: (parent.width - parent.spacing) / 2
            iconText: Networking.wifiEnabled ? "󰤨" : "󰤭"
            labelText: controlRoot.wifiSsid !== "" ? controlRoot.wifiSsid : "Disconnected"
            checked: Networking.wifiEnabled
            onClicked: controlRoot.toggleWifi()
            onRightClicked: controlRoot.openPage("wifi")
        }

        Pill {
            width: (parent.width - parent.spacing) / 2
            iconText: checked ? "󰂯" : "󰂲"
            labelText: {
                if (!controlRoot.btHasAdapter) return "No adapter"
                if (!controlRoot.btPowered) return "Off"
                if (controlRoot.btConnectedName !== "") return controlRoot.btConnectedName
                return "On"
            }
            checked: controlRoot.btPowered
            onClicked: {
                if (!controlRoot.btHasAdapter) {
                    controlRoot.openPage("bluetooth")
                    return
                }
                controlRoot.toggleBluetooth()
            }
            onRightClicked: controlRoot.openPage("bluetooth")
        }
    }

    Row {
        spacing: 8
        width: parent.width

        Pill {
            width: (parent.width - parent.spacing) / 2
            iconText: "󰅶"
            labelText: controlRoot.cafOn ? "Caff: on" : "Caff: off"
            checked: controlRoot.cafOn
            onClicked: controlRoot.cafProc.running = true
        }

        Pill {
            width: (parent.width - parent.spacing) / 2
            iconText: controlRoot.dndOn ? "󰂛" : "󰂚"
            labelText: controlRoot.dndOn ? "DND On" : "DND Off"
            checked: controlRoot.dndOn
            onClicked: NotifState.dndOn = !NotifState.dndOn
        }
    }

    Divider {}

    // ---- media ----
    Column {
        width: parent.width
        spacing: 6

        Item {
            width: parent.width
            height: 36

            Text {
                renderType: Text.NativeRendering
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Media"
                font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                color: PanelColors.textAccent
            }

            Row {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                spacing: 4
                visible: mediaSection.multiPlayer

                HeaderIconButton {
                    iconText: "\uF053"
                    onClicked: mediaSection.prevPlayer()
                }
                HeaderIconButton {
                    iconText: "\uF054"
                    onClicked: mediaSection.nextPlayer()
                }
            }
        }

        MediaSection { id: mediaSection; width: parent.width; controlRoot: controlRoot }
    }
}
