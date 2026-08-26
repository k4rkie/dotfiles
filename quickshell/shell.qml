//@ pragma IconTheme Papirus

import QtQuick
import Quickshell
import "launcher"
import "calendar"
import "controlcenter"

ShellRoot {
    AppLauncher {}
    CalendarPopup {}
    ControlCenter {}
    NotifPopup {}
}
