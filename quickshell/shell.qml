//@ pragma UseQApplication
//@ pragma IconTheme Papirus
// Use Vulkan (RADV) instead of EGL/GL: skips LLVM/gallium (~60 MB RSS) and
// renders on the GPU instead of llvmpipe.
//@ pragma Env QSG_RHI_BACKEND = vulkan

import QtQuick
import Quickshell
import "controlcenter"
import "controlcenter/components"
import "bar"

ShellRoot {
    // ControlCenter {}
    // NotifPopup {}
    StatusBar {}
}
