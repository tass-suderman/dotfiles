// Singleton that drives the launcher popup open/close state.
// Both the bar button and external IPC calls go through here.
pragma Singleton
import QtQuick

QtObject {
    property bool   isOpen: false
    property string mode:   "drun"

    function open(newMode) {
        mode   = newMode || "drun"
        isOpen = true
    }

    function close() {
        isOpen = false
    }

    function toggle(newMode) {
        if (isOpen && mode === newMode) close()
        else open(newMode)
    }
}
