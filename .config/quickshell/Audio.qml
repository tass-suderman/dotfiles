// Audio / volume widget – mirrors the waybar pulseaudio module.
// Click  → open pwvucontrol (matching on-click)
// Scroll up/down → pamixer -u/d 2 (matching on-scroll-up/down)
// Icons: muted=󰝟, low=󰖀, high=󰕾 (default icon list from modules.jsonc)
import Quickshell.Io
import QtQuick

Item {
    id: root

    property int  volume: 50
    property bool muted:  false

    function volumeIcon() {
        if (muted)         return "󰝟"
        if (volume === 0)  return "󰖀"
        if (volume < 50)   return "󰖀"
        return "󰕾"
    }

    function padNum(n) {
        return ("  " + n).slice(-3)
    }

    implicitWidth:  audioText.implicitWidth + 20
    implicitHeight: parent ? parent.height : 30

    // ── Polling timer ─────────────────────────────────────────────────────────
    Timer {
        interval:         1000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered:      volumeProc.running = true
    }

    // Single query: "muted=<true|false> vol=<0-100>"
    Process {
        id: volumeProc
        command: [
            "bash", "-c",
            "printf 'muted=%s vol=%s\n' $(pamixer --get-mute 2>/dev/null || echo false) $(pamixer --get-volume 2>/dev/null || echo 0)"
        ]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                let m = line.match(/muted=(\S+)\s+vol=(\d+)/)
                if (m) {
                    root.muted  = m[1] === "true"
                    root.volume = parseInt(m[2]) || 0
                }
            }
        }

        onExited: running = false
    }

    // One-shot processes for interactive commands
    Process { id: vucontrolProc; command: ["pwvucontrol"];            running: false; onExited: running = false }
    Process { id: volUpProc;     command: ["pamixer", "-ui", "2"];    running: false; onExited: running = false }
    Process { id: volDownProc;   command: ["pamixer", "-ud", "2"];    running: false; onExited: running = false }

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
        border.color: muted ? Colors.subtext0 : Colors.yellow
        border.width: 4

        Text {
            id:             audioText
            anchors.centerIn: parent
            text:           muted
                            ? "󰝟 muted"
                            : volumeIcon() + padNum(root.volume) + "%"
            color:          muted ? Colors.subtext0 : Colors.yellow
            font.family:    "Hack Nerd Font"
            font.pixelSize: 14
            font.weight:    Font.DemiBold
        }

        MouseArea {
            anchors.fill:    parent
            acceptedButtons: Qt.LeftButton
            cursorShape:     Qt.PointingHandCursor

            onClicked:       vucontrolProc.running = true

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) volUpProc.running   = true
                else                        volDownProc.running = true
            }

            HoverHandler {
                onHoveredChanged: parent.parent.opacity = hovered ? 0.8 : 1.0
            }
        }
    }
}
