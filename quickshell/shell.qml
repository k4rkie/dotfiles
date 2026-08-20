//@ pragma IconTheme Papirus

import QtQuick
import Quickshell
import "launcher"
import "wifi"
import "calendar"
import "media"

ShellRoot {
    AppLauncher {}
    WifiPopup {}
    CalendarPopup {}
    MediaPopup {}
}
