import QtQuick
import "../theme"
Rectangle {
        id: actRow
        property string iconText: ""
        property string labelText: ""
        property bool danger: false
        signal clicked()
        width: parent.width; height: 46; radius: 0
        color: actMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
        border.width: 1
        border.color: PanelColors.border

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                renderType: Text.NativeRendering
                text: actRow.iconText
                font.pixelSize: 16; font.family: FontConfig.fontFamily
                color: actRow.danger ? PanelColors.error : PanelColors.textMain
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                renderType: Text.NativeRendering
                text: actRow.labelText
                font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                color: actRow.danger ? PanelColors.error : PanelColors.textMain
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: actMouse; z: 2; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actRow.clicked()
        }
    }
