import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../theme"

Rectangle {
    id: root
    height: 26
    width: trayRow.implicitWidth + 12
    visible: SystemTray.items.values.length > 0
    color: PanelColors.barBackground
    border.color: PanelColors.border
    border.width: 2
    radius: 0

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: SystemTray.items

            IconImage {
                required property SystemTrayItem modelData
                source: modelData.icon
                implicitSize: 14
                width: 14
                height: 14
                asynchronous: true

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: parent.opacity = 0.7
                    onExited: parent.opacity = 1.0
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) modelData.activate()
                        else if (modelData.hasMenu) modelData.display(parent, 0, -parent.height - 4)
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onEntered: parent.opacity = 0.85
        onExited: parent.opacity = 1.0
        onClicked: (mouse) => mouse.accepted = false
    }
}
