pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// ── NotifState ───────────────────────────────────────────────────────────────
// Owns the NotificationServer plus the history/toast models so the control
// center page (NotifState.history) and the toast popup window
// (NotifState.toasts) share one backend without cross-file coupling.
Singleton {
    id: root

    property bool dndOn: false

    // True shortly after (re)load. The server replays its retained tracked
    // notifications into onNotification on every config reload; those must
    // refresh the history but not re-toast on screen.
    property bool ready: false
    Component.onCompleted: bootDelay.restart()
    Timer {
        id: bootDelay
        interval: 1000
        onTriggered: root.ready = true
    }

    readonly property alias history: historyModel
    readonly property alias toasts: toastModel

    ListModel { id: historyModel }
    ListModel { id: toastModel }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        onNotification: (notification) => {
            if (root.dndOn) {
                notification.dismiss()
                return
            }
            notification.tracked = true
            var entry = {
                notification: notification,
                appName: notification.appName,
                summary: notification.summary,
                body: notification.body,
                image: notification.image,
                appIcon: notification.appIcon,
                urgency: notification.urgency,
                expireTimeout: notification.expireTimeout,
                timestamp: Date.now()
            }
            historyModel.insert(0, entry)
            if (root.ready) toastModel.append(entry)
        }
    }

    // Dismiss a history row (also drops it from the history list).
    function removeNotification(idx) {
        var item = historyModel.get(idx)
        if (item && item.notification) {
            try { item.notification.dismiss() } catch (e) {}
        }
        historyModel.remove(idx)
    }

    function clearNotifications() {
        for (var i = historyModel.count - 1; i >= 0; i--)
            removeNotification(i)
    }

    // Remove a toast (matched by notification identity so stale delegate
    // indices never remove the wrong card). Keeps it in the history.
    function dismissToast(entry) {
        for (var i = toastModel.count - 1; i >= 0; i--) {
            if (toastModel.get(i).notification === entry.notification) {
                toastModel.remove(i)
                break
            }
        }
        try { entry.notification.dismiss() } catch (e) {}
    }
}
