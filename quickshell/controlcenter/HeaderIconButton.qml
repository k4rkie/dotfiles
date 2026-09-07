import QtQuick
import "../theme"
Rectangle {
        id: hbtn
        property string iconText: ""
        property bool isActive: false
        signal clicked()
        width: 36; height: 36; radius: 0
        color: hmouse.containsMouse || isActive ? Qt.lighter(PanelColors.rowBackground, 1.35) : PanelColors.rowBackground
        border.width: 1
        border.color: PanelColors.border
        Behavior on color { ColorAnimation { duration: 0 } }
        Text {
            renderType: Text.NativeRendering
            anchors.centerIn: parent
            text: hbtn.iconText
            font.pixelSize: 16; font.family: FontConfig.fontFamily
            color: hmouse.containsMouse || hbtn.isActive ? PanelColors.textAccent : PanelColors.textMain
            Behavior on color { ColorAnimation { duration: 0 } }
        }
        MouseArea {
            id: hmouse; z: 2; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: hbtn.clicked()
        }
    }
