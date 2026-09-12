import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: root
    color: "transparent"

    property bool barVisible: true
    visible: barVisible
    exclusionMode: barVisible ? ExclusionMode.Auto : ExclusionMode.Ignore
    exclusiveZone: barVisible ? 34 : 0

    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: 34
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "quickshell:bar"

    IpcHandler {
        target: "bar"
        function toggle(): void { root.barVisible = !root.barVisible }
        function show(): void { root.barVisible = true }
        function hide(): void { root.barVisible = false }
    }

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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            spacing: 0

            Clock {}
        } 

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 4
            spacing: 8

            Memory {}
            Storage {}
            Battery {}
            Wifi {}
            Tray {}
        }
    }
}
