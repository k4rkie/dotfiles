import QtQuick
import "../theme"
Rectangle {
        id: tswitch
        property bool checked: false
        signal toggled()
        width: 34; height: 18; radius: 0
        color: tswitch.checked ? PanelColors.pillActive : PanelColors.rowBackground
        border.width: 1
        border.color: PanelColors.border

        Rectangle {
            x: tswitch.checked ? parent.width - width - 2 : 2
            anchors.verticalCenter: parent.verticalCenter
            width: 14; height: 14; radius: 0
            color: tswitch.checked ? PanelColors.pillForeground : PanelColors.textDim
            Behavior on x { NumberAnimation { duration: 0 } }
        }
        MouseArea {
            id: tswitchMouse
            z: 2
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: tswitch.toggled()
        }
    }
