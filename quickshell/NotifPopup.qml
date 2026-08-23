import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "theme"

// Transient notification toasts, stacked at the top-right corner of the
// screen. Fed by the shared NotifState singleton; each card auto-expires after
// 5s (or on click), while the notification stays in the control center's
// history page.
PanelWindow {
    id: root
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors { top: true; right: true }
    margins { top: 8; right: 8 }

    implicitWidth: 340
    implicitHeight: toastList.contentHeight
    visible: NotifState.toasts.count > 0

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    ListView {
        id: toastList
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: contentHeight
        spacing: 6
        interactive: false
        model: NotifState.toasts

        delegate: Rectangle {
            id: toastCard
            required property var modelData

            readonly property bool isCritical:
                modelData.urgency === NotificationUrgency.Critical

            // icon hint: raw image → file path → theme icon name → letter
            readonly property string iconSource: {
                if (modelData.image !== "") return modelData.image
                if (modelData.appIcon === "") return ""
                if (modelData.appIcon.startsWith("/")) return "file://" + modelData.appIcon
                return Quickshell.iconPath(modelData.appIcon)
            }

            width: toastList.width
            height: 52; radius: 0
            color: PanelColors.popupBackground
            border.color: "#090909"
            border.width: 2

            Row {
                anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                spacing: 8

                Rectangle {
                    width: 30; height: 30; radius: 0
                    anchors.verticalCenter: parent.verticalCenter
                    color: PanelColors.rowBackground
                    border.width: 1
                    border.color: PanelColors.border
                    clip: true

                    Image {
                        anchors.fill: parent; anchors.margins: 2
                        source: toastCard.iconSource
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: toastCard.iconSource !== ""
                    }
                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        visible: toastCard.iconSource === ""
                        text: toastCard.modelData.appName !== "" ? toastCard.modelData.appName.charAt(0).toUpperCase() : "?"
                        font.pixelSize: 16; font.bold: true; font.family: "MapleMono NF"
                        color: PanelColors.textAccent
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    width: parent.width - 30 - parent.spacing

                    Text {
                        renderType: Text.NativeRendering
                        width: parent.width
                        text: toastCard.modelData.appName !== "" ? toastCard.modelData.appName : "notification"
                        font.pixelSize: 12; font.bold: true; font.family: "MapleMono NF"
                        color: PanelColors.textDim
                        elide: Text.ElideRight
                    }
                    Text {
                        renderType: Text.NativeRendering
                        width: parent.width
                        text: toastCard.modelData.summary + (toastCard.modelData.body !== "" ? " — " + toastCard.modelData.body : "")
                        font.pixelSize: 13; font.family: "MapleMono NF"
                        color: PanelColors.textMain
                        elide: Text.ElideRight
                    }
                }
            }

            MouseArea {
                anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotifState.dismissToast(toastCard.modelData)
            }

            Timer {
                interval: toastCard.modelData.expireTimeout > 0 ? toastCard.modelData.expireTimeout : 5000
                running: !toastCard.isCritical
                onTriggered: NotifState.dismissToast(toastCard.modelData)
            }
        }
    }
}
