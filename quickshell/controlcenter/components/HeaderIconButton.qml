import QtQuick
import "../../theme"
Rectangle {
        id: hbtn
        property string iconText: ""
        property bool isActive: false
        signal clicked()
        width: 36; height: 36; radius: 0
        color: isActive ? Qt.darker(PanelColors.rowBackground, 1.2) : (hmouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.35) : PanelColors.rowBackground)
        border.width: 1
        border.color: isActive ? PanelColors.textAccent : PanelColors.border
        Text {
            renderType: Text.NativeRendering
            anchors.centerIn: parent
            text: hbtn.iconText
            font.pixelSize: 16; font.family: FontConfig.fontFamily
            color: hmouse.containsMouse || hbtn.isActive ? PanelColors.textAccent : PanelColors.textMain
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: 20; height: 2
            radius: 1
            color: PanelColors.textAccent
            visible: hbtn.isActive
        }
        MouseArea {
            id: hmouse; z: 2; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: hbtn.clicked()
        }
    }
