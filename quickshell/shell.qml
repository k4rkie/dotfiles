//@ pragma IconTheme Papirus

import QtQuick
import Quickshell
import "launcher"
import "calendar"
import "media"
import "bar"
import "controlcenter"

ShellRoot {
    AppLauncher {}
    CalendarPopup {}
    MediaPopup {}
    ControlCenter {}
    NotifPopup {}
    StatusBar {}
}
