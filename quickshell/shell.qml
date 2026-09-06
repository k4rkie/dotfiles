//@ pragma IconTheme Papirus

import QtQuick
import Quickshell
import "launcher"
import "calendar"
import "controlcenter"
import "bar"

ShellRoot {
    AppLauncher {}
    CalendarPopup {}
    ControlCenter {}
    NotifPopup {}
    StatusBar {}
}
