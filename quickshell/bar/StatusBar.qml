import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: root
    color: "transparent"

    anchors {
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Auto
    exclusiveZone: 30

    implicitHeight: 32
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell:bar"

    Rectangle {
        anchors.fill: parent
        color: PanelColors.barBackground
        border.width: 0

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            spacing: 0

            Workspaces {}
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 4
            spacing: 8

            Memory {}
            Clock {}
            Battery {}
            ControlCenterButton {}
            Tray {}
        }
    }
}
