import QtQuick
import Quickshell
import "../theme"

Rectangle {
  id: root 
  height: 30
  width: 1
  color: "transparent"

  Text {
    id: label
    anchors.centerIn: parent
    text: ":"
    font.family: FontConfig.fontFamily
    font.pixelSize: FontConfig.size
    color: PanelColors.base05
    opacity: 0.2
  }
}
