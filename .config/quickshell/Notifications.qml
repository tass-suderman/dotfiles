// SwayNC notification widget – mirrors custom/notification.
// Subscribes to swaync-client -swb for live state updates.
// Left-click  → toggle notification panel  (swaync-client -t -sw)
// Right-click → toggle Do Not Disturb      (swaync-client -d -sw)
// Icons mirror the format-icons map in modules.jsonc.
import Quickshell.Io
import QtQuick

Item {
    id: root

    property bool hasNotification: false
    property bool dnd:             false
    property bool inhibited:       false

    // Icon selection mirrors waybar's format-icons table exactly.
    function notifIcon() {
        if (dnd && inhibited && hasNotification) return ""
        if (dnd && inhibited)                    return ""
        if (dnd && hasNotification)              return ""
        if (dnd)                                 return ""
        if (inhibited && hasNotification)        return ""
        if (inhibited)                           return ""
        if (hasNotification)                     return ""
        return ""
    }

    implicitWidth:  notifLabel.implicitWidth + 20
    implicitHeight: parent ? parent.height : 30

    // ── swaync subscription ───────────────────────────────────────────────────
    // swaync-client -swb prints a JSON object on state change and stays running.
    Process {
        id: swayncProc
        command: ["swaync-client", "-swb"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                try {
                    let d = JSON.parse(line)
                    root.hasNotification = (d.count  > 0)
                    root.dnd             = d.dnd      === true
                    root.inhibited       = d.inhibited === true
                } catch (e) { /* ignore malformed lines */ }
            }
        }

        // Restart if swaync-client exits (e.g. swaync restarts)
        onExited: running = true
    }

    // One-shot processes for panel and DnD toggle
    Process { id: togglePanelProc; command: ["swaync-client", "-t", "-sw"]; running: false; onExited: running = false }
    Process { id: toggleDndProc;   command: ["swaync-client", "-d", "-sw"]; running: false; onExited: running = false }

    // ── Visual ────────────────────────────────────────────────────────────────
    Rectangle {
        anchors {
            fill:         parent
            topMargin:    6
            bottomMargin: 6
            rightMargin:  2
        }

        color:        Colors.backgroundPrimary
        radius:       12
        border.color: Colors.lavender
        border.width: 4

        Text {
            id:             notifLabel
            anchors.centerIn: parent
            text:           root.notifIcon()
            color:          Colors.lavender
            font.family:    "Hack Nerd Font"
            font.pixelSize: 16
            font.weight:    Font.DemiBold
        }

        MouseArea {
            anchors.fill:    parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape:     Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) toggleDndProc.running   = true
                else                                 togglePanelProc.running = true
            }

            HoverHandler {
                onHoveredChanged: parent.parent.opacity = hovered ? 0.8 : 1.0
            }
        }
    }
}
