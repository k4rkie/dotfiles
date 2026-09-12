import QtQuick
import ".."
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Widgets
import "../../theme"
import "../apps"
import "../components"


            Column {
    required property var controlRoot
                width: parent.width
                spacing: 8
                visible: controlRoot.page === "power"

                ActionRow {
                    iconText: "󰌾"; labelText: "Lock"
                    onClicked: { controlRoot.runSession("pidof hyprlock >/dev/null || hyprlock"); controlRoot.close() }
                }
                ActionRow {
                    iconText: "󰍃"; labelText: "Logout"
                    onClicked: { controlRoot.runSession("loginctl terminate-session ${XDG_SESSION_ID}"); controlRoot.close() }
                }
                ActionRow {
                    iconText: "󰤄"; labelText: "Suspend"
                    onClicked: { controlRoot.runSession("systemctl suspend"); controlRoot.close() }
                }
                ActionRow {
                    iconText: "󰜎"; labelText: "Restart"
                    onClicked: { controlRoot.runSession("systemctl reboot"); controlRoot.close() }
                }
                ActionRow {
                    iconText: "󰐥"; labelText: "Power Off"
                    onClicked: { controlRoot.runSession("systemctl poweroff"); controlRoot.close() }
                }
            }
