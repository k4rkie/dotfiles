import QtQuick
import "../../theme"
Rectangle {
        id: pill
        property string iconText: ""
        property string labelText: ""
        property bool checked: false
        property bool isActive: false
        property color accentColor: PanelColors.pillActive
        signal clicked()
        signal rightClicked()
        height: 42; radius: 0
        color: {
            if (checked || isActive)
                return pillMouse.containsMouse ? Qt.lighter(accentColor, 1.15) : accentColor
            return pillMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
        }
        border.width: 1
        border.color: checked || isActive ? Qt.darker(accentColor, 1.2) : PanelColors.border

        Row {
            anchors.centerIn: parent
            spacing: 7

            Text {
                renderType: Text.NativeRendering
                text: pill.iconText
                font.pixelSize: 16; font.family: FontConfig.fontFamily
                color: pill.checked || pill.isActive ? PanelColors.pillForeground
                    : pillMouse.containsMouse ? PanelColors.textAccent : PanelColors.textMain
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                renderType: Text.NativeRendering
                text: pill.labelText
                font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                width: Math.max(0, pill.width - 38)
                elide: Text.ElideRight
                color: pill.checked || pill.isActive ? PanelColors.pillForeground
                    : pillMouse.containsMouse ? PanelColors.textAccent : PanelColors.textDim
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: pillMouse; z: 2; anchors.fill: parent; hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) pill.rightClicked()
                else pill.clicked()
            }
        }
    }
