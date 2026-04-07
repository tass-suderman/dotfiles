// Battery widget – mirrors the waybar battery module.
// Reads capacity and status from /sys/class/power_supply/BAT0/ every 30 s.
// States: warning ≤ 30 %, critical ≤ 15 % (matching modules.jsonc).
// Icons: ["󰂎","󱊡","󱊢","󱊣","󰁹"] (0–24 / 25–49 / 50–74 / 75–99 / 100).
import Quickshell.Io
import QtQuick

Item {
    id: root

    property int    capacity:   100
    property string status:     "Full"
    property bool   isCharging: false
    property bool   isWarning:  false
    property bool   isCritical: false

    readonly property var icons: ["󰂎", "󱊡", "󱊢", "󱊣", "󰁹"]

    function batteryIcon() {
        let idx = Math.min(Math.floor(capacity / 25), 4)
        return icons[idx]
    }

    function padNum(n) {
        // Right-align the number in 3 characters, matching "{capacity: >3}%"
        return ("  " + n).slice(-3)
    }

    implicitWidth:  batteryText.implicitWidth + 20
    implicitHeight: parent ? parent.height : 30

    // ── Polling timer ─────────────────────────────────────────────────────────
    Timer {
        interval:         30000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: {
            capacityProc.running = true
            statusProc.running   = true
        }
    }

    Process {
        id: capacityProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                let v = parseInt(line)
                if (!isNaN(v)) root.capacity = v
                root.isWarning  = root.capacity <= 30 && !root.isCharging
                root.isCritical = root.capacity <= 15 && !root.isCharging
            }
        }
        onExited: running = false
    }

    Process {
        id: statusProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Full"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                root.status     = line.trim()
                root.isCharging = root.status === "Charging"
                // Re-evaluate warning/critical after charging state changes
                root.isWarning  = root.capacity <= 30 && !root.isCharging
                root.isCritical = root.capacity <= 15 && !root.isCharging
            }
        }
        onExited: running = false
    }

    // ── Visual ────────────────────────────────────────────────────────────────
    Rectangle {
        anchors {
            fill:         parent
            topMargin:    6
            bottomMargin: 6
        }

        color: isCritical ? Colors.error
               : isWarning  ? Colors.warning
               : Colors.backgroundPrimary

        radius: 12

        border.color: isCharging ? Colors.yellow
                      : isCritical ? Colors.maroon
                      : isWarning  ? Colors.peach
                      : Colors.green
        border.width: 4

        Text {
            id:             batteryText
            anchors.centerIn: parent
            text:           batteryIcon() + padNum(root.capacity) + "%"
            color:          (isCritical || isWarning) ? Colors.base
                            : isCharging              ? Colors.yellow
                            : Colors.green
            font.family:    "Hack Nerd Font"
            font.pixelSize: 14
            font.weight:    Font.DemiBold
        }

        HoverHandler {
            onHoveredChanged: parent.opacity = hovered ? 0.8 : 1.0
        }
    }
}
