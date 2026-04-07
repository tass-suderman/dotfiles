// Bluetooth widget – mirrors the waybar bluetooth module.
// Shows "" when Bluetooth is on but no device is connected.
// Shows "󰂯<battery>%" when a device is connected (battery via bluetoothctl).
// Tooltip shows the connected device alias, matching tooltip-format-connected.
import Quickshell.Io
import QtQuick
import QtQuick.Controls

Item {
    id: root

    property bool   connected:         false
    property string deviceAlias:       ""
    property int    deviceBattery:     -1   // -1 = unknown

    function displayText() {
        if (!connected) return ""
        if (deviceBattery >= 0) return "󰂯" + deviceBattery + "%"
        return "󰂯"
    }

    implicitWidth:  btLabel.implicitWidth + 20
    implicitHeight: parent ? parent.height : 30

    // ── Polling timer ─────────────────────────────────────────────────────────
    Timer {
        interval:         10000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered:      btProc.running = true
    }

    // Query bluetoothctl for connection status, alias, and battery level.
    Process {
        id: btProc
        command: [
            "bash", "-c",
            // Print one line: "connected:<alias>:<battery>" or "off" or "on"
            [
                "if ! bluetoothctl show | grep -q 'Powered: yes'; then echo off; exit; fi",
                "INFO=$(bluetoothctl info 2>/dev/null)",
                "if echo \"$INFO\" | grep -q 'Connected: yes'; then",
                "  ALIAS=$(echo \"$INFO\" | awk '/Alias:/{$1=\"\"; print substr($0,2)}')",
                "  BATT=$(echo \"$INFO\" | awk '/Battery Percentage:/{gsub(/[()]/,\"\",$NF); print $NF}')",
                "  echo \"connected:${ALIAS}:${BATT:-}\"",
                "else",
                "  echo on",
                "fi"
            ].join("; ")
        ]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                line = line.trim()
                if (line === "off" || line === "on") {
                    root.connected     = false
                    root.deviceAlias   = ""
                    root.deviceBattery = -1
                } else if (line.startsWith("connected:")) {
                    let parts = line.split(":")
                    root.connected     = true
                    root.deviceAlias   = parts[1] || ""
                    root.deviceBattery = parseInt(parts[2]) || -1
                }
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

        color: Colors.backgroundPrimary

        Text {
            id:             btLabel
            anchors.centerIn: parent
            text:           root.displayText()
            color:          Colors.blue
            font.family:    "Hack Nerd Font"
            font.pixelSize: 14
            font.weight:    Font.DemiBold
        }

        // Tooltip showing device alias when connected
        ToolTip {
            id:      btTooltip
            visible: false
            text:    root.deviceAlias
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                if (root.connected) btTooltip.visible = true
                parent.opacity = 0.8
            }
            onExited: {
                btTooltip.visible = false
                parent.opacity = 1.0
            }
        }
    }
}
