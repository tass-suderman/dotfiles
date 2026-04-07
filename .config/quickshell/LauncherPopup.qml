// Launcher popup – replaces rofi.
//
// Visual behaviour (per requirements):
//   • Slides DOWN from behind the bar (WlrLayer.Top) when opened.
//   • Slides back UP behind the bar when closed.
//   • Animation: 500 ms OutCubic easing.
//   • z-index: WlrLayer.Bottom  →  bar (WlrLayer.Top) always renders on top.
//
// Supported modes (matching launcher.sh / keybindings.conf):
//   drun    – installed applications via DesktopEntries
//   window  – open Hyprland windows
//   run     – arbitrary shell command
//   power   – shutdown / reboot / suspend / hibernate / logout / lock
//   emoji   – common emoji picker (copies to clipboard via wl-copy)
//   browser – simple file browser rooted at $HOME
//   (clipboard mode is handled externally by clipcat-menu, not this popup)
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.DesktopEntries
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: root

    // ── Layer shell setup ──────────────────────────────────────────────────────
    // Bottom layer so the bar (Top layer) sits visually above us at all times.
    WlrLayershell.layer:         WlrLayer.Bottom
    WlrLayershell.namespace:     "quickshell-launcher"
    WlrLayershell.keyboardFocus: LauncherService.isOpen
                                 ? WlrKeyboardFocus.Exclusive
                                 : WlrKeyboardFocus.None

    anchors { top: true; left: true; right: true }

    // The window is always the full height so the compositor clip gives us the
    // "slide from under the bar" effect without resizing the surface.
    readonly property int barHeight:     30
    readonly property int contentHeight: 540   // launcher pane height
    height: barHeight + contentHeight           // 570 px total surface

    exclusiveZone: 0    // never push app windows down
    color:         "transparent"

    // ── Launcher width (≈35em at 14 px ≈ 520 px, matching the rasi theme) ────
    readonly property int launcherWidth: 520

    // ═════════════════════════════════════════════════════════════════════════
    // Mode data
    // ═════════════════════════════════════════════════════════════════════════

    readonly property var powerItems: [
        { name: "Shutdown",  icon: "󰐥", cmd: ["systemctl", "poweroff"]              },
        { name: "Reboot",    icon: "󰑓", cmd: ["systemctl", "reboot"]                },
        { name: "Suspend",   icon: "󰤄", cmd: ["systemctl", "suspend"]               },
        { name: "Hibernate", icon: "󰒲", cmd: ["systemctl", "hibernate"]             },
        { name: "Logout",    icon: "󰍃", cmd: ["hyprctl", "dispatch", "exit"]        },
        { name: "Lock",      icon: "󰌾", cmd: ["hyprlock"]                           }
    ]

    readonly property var emojiItems: [
        { name: "grinning face",        emoji: "😀" }, { name: "joy",             emoji: "😂" },
        { name: "rofl",                 emoji: "🤣" }, { name: "smile",           emoji: "😊" },
        { name: "wink",                 emoji: "😉" }, { name: "sunglasses",      emoji: "😎" },
        { name: "heart eyes",           emoji: "😍" }, { name: "thinking",        emoji: "🤔" },
        { name: "sob",                  emoji: "😭" }, { name: "party face",      emoji: "🥳" },
        { name: "red heart",            emoji: "❤️" }, { name: "thumbs up",       emoji: "👍" },
        { name: "thumbs down",          emoji: "👎" }, { name: "clap",            emoji: "👏" },
        { name: "wave",                 emoji: "👋" }, { name: "muscle",          emoji: "💪" },
        { name: "pray",                 emoji: "🙏" }, { name: "ok hand",         emoji: "👌" },
        { name: "point right",          emoji: "👉" }, { name: "point left",      emoji: "👈" },
        { name: "point up",             emoji: "👆" }, { name: "point down",      emoji: "👇" },
        { name: "eyes",                 emoji: "👀" }, { name: "fire",            emoji: "🔥" },
        { name: "sparkles",             emoji: "✨" }, { name: "star",            emoji: "⭐" },
        { name: "100",                  emoji: "💯" }, { name: "check",           emoji: "✅" },
        { name: "cross",                emoji: "❌" }, { name: "warning",         emoji: "⚠️" },
        { name: "question",             emoji: "❓" }, { name: "party",           emoji: "🎉" },
        { name: "tada",                 emoji: "🎊" }, { name: "rocket",          emoji: "🚀" },
        { name: "computer",             emoji: "💻" }, { name: "phone",           emoji: "📱" },
        { name: "lock",                 emoji: "🔒" }, { name: "key",             emoji: "🔑" },
        { name: "magnifier",            emoji: "🔍" }, { name: "link",            emoji: "🔗" },
        { name: "mail",                 emoji: "📧" }, { name: "folder",          emoji: "📁" },
        { name: "file",                 emoji: "📄" }, { name: "trash",           emoji: "🗑️" },
        { name: "clipboard",            emoji: "📋" }, { name: "pencil",          emoji: "✏️" },
        { name: "books",                emoji: "📚" }, { name: "calendar",        emoji: "📅" },
        { name: "clock",                emoji: "🕐" }, { name: "money",           emoji: "💰" },
        { name: "gem",                  emoji: "💎" }, { name: "crown",           emoji: "👑" },
        { name: "coffee",               emoji: "☕" }, { name: "pizza",           emoji: "🍕" },
        { name: "beer",                 emoji: "🍺" }, { name: "wine",            emoji: "🍷" },
        { name: "cat",                  emoji: "🐱" }, { name: "dog",             emoji: "🐶" },
        { name: "snake",                emoji: "🐍" }, { name: "bug",             emoji: "🐛" },
        { name: "robot",                emoji: "🤖" }, { name: "ghost",           emoji: "👻" },
        { name: "skull",                emoji: "💀" }, { name: "sun",             emoji: "☀️" },
        { name: "moon",                 emoji: "🌙" }, { name: "rainbow",         emoji: "🌈" },
        { name: "lightning",            emoji: "⚡" }, { name: "snow",            emoji: "❄️" },
        { name: "music",                emoji: "🎵" }, { name: "headphones",      emoji: "🎧" },
        { name: "target",               emoji: "🎯" }, { name: "wrench",          emoji: "🔧" },
        { name: "chart up",             emoji: "📈" }, { name: "globe",           emoji: "🌍" }
    ]

    // ── File browser state ─────────────────────────────────────────────────────
    property string currentBrowserDir: ""
    property var    browserEntries:    []

    // Resolve $HOME once at startup
    Process {
        id: getHomeProc
        command: ["bash", "-c", "echo $HOME"]
        running: true
        stdout: SplitParser {
            onRead: function(line) { root.currentBrowserDir = line.trim() }
        }
        onExited: running = false
    }

    Process {
        id: lsProc
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                if (line.length > 0) root.browserEntries = root.browserEntries.concat([line])
            }
        }
        onRunningChanged: if (running) root.browserEntries = []
        onExited: { running = false; root.rebuildModel() }
    }

    // ── Execution helpers ──────────────────────────────────────────────────────
    Process { id: launchProc; running: false; onExited: running = false }
    Process { id: clipProc;   running: false; onExited: running = false }

    // ═════════════════════════════════════════════════════════════════════════
    // Filtered model (plain JS array shown in ListView)
    // ═════════════════════════════════════════════════════════════════════════

    property var displayModel: []

    function rebuildModel() {
        let q    = searchField.text.toLowerCase()
        let mode = LauncherService.mode
        let out  = []

        if (mode === "drun") {
            let all = []
            for (let i = 0; i < DesktopEntries.applications.count; i++) {
                let app = DesktopEntries.applications.get(i)
                if (app.noDisplay) continue
                let n = app.name.toLowerCase()
                let g = (app.genericName || "").toLowerCase()
                if (!q || n.includes(q) || g.includes(q))
                    all.push({ type: "app", entry: app, name: app.name, icon: app.icon })
            }
            all.sort((a, b) => a.name.localeCompare(b.name))
            out = all.slice(0, 10)

        } else if (mode === "window") {
            for (let i = 0; i < Hyprland.clients.count && out.length < 10; i++) {
                let c = Hyprland.clients.get(i)
                let t = c.title.toLowerCase()
                let cl = c.class.toLowerCase()
                if (!q || t.includes(q) || cl.includes(q))
                    out.push({ type: "window", client: c, name: c.title, subtitle: c.class })
            }

        } else if (mode === "power") {
            for (let i = 0; i < powerItems.length; i++) {
                let p = powerItems[i]
                if (!q || p.name.toLowerCase().includes(q))
                    out.push({ type: "power", name: p.name, icon: p.icon, cmd: p.cmd })
            }

        } else if (mode === "run") {
            if (q) out.push({ type: "run", name: q })

        } else if (mode === "emoji") {
            for (let i = 0; i < emojiItems.length && out.length < 10; i++) {
                let e = emojiItems[i]
                if (!q || e.name.includes(q))
                    out.push({ type: "emoji", name: e.name, emoji: e.emoji })
            }

        } else if (mode === "browser") {
            for (let i = 0; i < browserEntries.length && out.length < 10; i++) {
                let f = browserEntries[i]
                if (f === "./" || (!q || f.toLowerCase().includes(q)))
                    out.push({ type: "file", name: f,
                               path: root.currentBrowserDir + "/" + f.replace(/\/$/, "") })
            }
        }

        displayModel = out
    }

    function activateItem(item) {
        if (!item) return

        if (item.type === "app") {
            item.entry.launch()
            LauncherService.close()

        } else if (item.type === "window") {
            Hyprland.dispatch("focuswindow address:" + item.client.address)
            LauncherService.close()

        } else if (item.type === "power") {
            launchProc.command = item.cmd
            launchProc.running = true
            LauncherService.close()

        } else if (item.type === "run") {
            launchProc.command = ["bash", "-c", item.name]
            launchProc.running = true
            LauncherService.close()

        } else if (item.type === "emoji") {
            // Pass emoji as an argument rather than interpolating into a shell string
            clipProc.command = ["wl-copy", item.emoji]
            clipProc.running  = true
            LauncherService.close()

        } else if (item.type === "file") {
            if (item.name.endsWith("/")) {
                // Navigate into directory
                root.currentBrowserDir = item.path
                searchField.text = ""
                // Pass the directory as a positional parameter to avoid shell injection
                lsProc.command = ["bash", "-c",
                                  "ls -1ap \"$1\" 2>/dev/null | head -60",
                                  "--", root.currentBrowserDir]
                lsProc.running = true
            } else {
                launchProc.command = ["xdg-open", item.path]
                launchProc.running = true
                LauncherService.close()
            }
        }
    }

    // ── React to LauncherService state changes ─────────────────────────────────
    Connections {
        target: LauncherService
        function onIsOpenChanged() {
            if (!LauncherService.isOpen) return

            searchField.text    = ""
            listView.currentIndex = 0

            if (LauncherService.mode === "browser") {
                // Pass the directory as a positional parameter to avoid shell injection
                lsProc.command = ["bash", "-c",
                                  "ls -1ap \"$1\" 2>/dev/null | head -60",
                                  "--", root.currentBrowserDir]
                lsProc.running = true
            } else {
                rebuildModel()
            }

            // Delay focus slightly so the slide animation is already under way
            focusTimer.restart()
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: searchField.forceActiveFocus()
    }

    // ═════════════════════════════════════════════════════════════════════════
    // Visual
    // ═════════════════════════════════════════════════════════════════════════

    // The launcher pane lives inside the full-height surface.
    // When closed  : y = -contentHeight  → entirely above the surface origin → invisible
    // When open    : y = barHeight        → starts just below the bar
    // The bar (WlrLayer.Top) covers the first `barHeight` pixels, so the pane
    // appears to emerge from behind it.
    Rectangle {
        id: pane

        width:  root.launcherWidth
        height: root.contentHeight
        anchors.horizontalCenter: parent.horizontalCenter

        y: LauncherService.isOpen ? root.barHeight : -root.contentHeight

        Behavior on y {
            NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
        }

        // sadbean window-background: #0f0f0f with alpha 0xf0 ≈ 94 %
        color:        Qt.rgba(0.059, 0.059, 0.059, 0.941)
        border.color: Colors.borderColor
        border.width: 2
        // Top corners are hidden behind the bar, so uniform radius is fine.
        radius: 10

        ColumnLayout {
            anchors { fill: parent; margins: 10 }
            spacing: 8

            // ── Input bar ──────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height:      48
                color:       Colors.backgroundHover
                border.color: Colors.borderColor
                border.width: 2
                radius:      10

                RowLayout {
                    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                    spacing: 8

                    // Mode icon (prompt) – matches general.rasi display-name icons
                    Text {
                        text: {
                            switch (LauncherService.mode) {
                                case "drun":    return ""
                                case "run":     return ""
                                case "window":  return ""
                                case "emoji":   return ""
                                case "browser": return ""
                                case "power":   return ""
                                default:        return ""
                            }
                        }
                        color:          Colors.lavender
                        font.family:    "Hack Nerd Font"
                        font.pixelSize: 16
                    }

                    TextInput {
                        id: searchField
                        Layout.fillWidth: true
                        color:           Colors.lavender
                        selectionColor:  Colors.mauve
                        font.family:     "JetBrains Mono"
                        font.pixelSize:  14
                        font.weight:     Font.Medium
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: {
                            listView.currentIndex = 0
                            root.rebuildModel()
                        }

                        Keys.onReturnPressed:  root.activateItem(root.displayModel[listView.currentIndex])
                        Keys.onTabPressed:     { if (listView.currentIndex < listView.count - 1) listView.currentIndex++ }
                        Keys.onUpPressed:      { if (listView.currentIndex > 0) listView.currentIndex-- }
                        Keys.onDownPressed:    { if (listView.currentIndex < listView.count - 1) listView.currentIndex++ }
                        Keys.onEscapePressed:  LauncherService.close()
                    }
                }
            }

            // ── Results list ───────────────────────────────────────────────────
            // sadbean: lines: 10, element padding: 10px, element-icon size: 18px
            ListView {
                id: listView
                Layout.fillWidth:  true
                Layout.fillHeight: true
                clip: true
                model: root.displayModel

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width:  listView.width
                    height: 44
                    radius: 10

                    // selected: lavender background (matching "element selected")
                    color: listView.currentIndex === index
                           ? Colors.lavender
                           : "transparent"

                    RowLayout {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                        spacing: 10

                        // Left glyph: nerd-font icon for power/emoji, or nothing
                        Text {
                            visible:        modelData.emoji !== undefined || modelData.icon !== undefined
                            text:           modelData.emoji || modelData.icon || ""
                            color:          listView.currentIndex === index ? Colors.base : Colors.lavender
                            font.family:    "Hack Nerd Font"
                            font.pixelSize: 16
                        }

                        // Name + optional subtitle (window class, emoji name, …)
                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                width:          parent.width
                                text:           modelData.name || ""
                                color:          listView.currentIndex === index ? Colors.base : Colors.lavender
                                font.family:    "JetBrains Mono"
                                font.pixelSize: 14
                                font.weight:    Font.Medium
                                elide:          Text.ElideRight
                            }

                            Text {
                                visible:        (modelData.subtitle || "") !== ""
                                width:          parent.width
                                text:           modelData.subtitle || ""
                                color:          listView.currentIndex === index
                                                ? Colors.base
                                                : Colors.subtext0
                                font.family:    "JetBrains Mono"
                                font.pixelSize: 11
                                elide:          Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            listView.currentIndex = index
                            root.activateItem(modelData)
                        }
                    }
                }
            }

            // ── Browser path breadcrumb ────────────────────────────────────────
            Text {
                visible:        LauncherService.mode === "browser"
                Layout.fillWidth: true
                text:           root.currentBrowserDir
                color:          Colors.subtext0
                font.family:    "JetBrains Mono"
                font.pixelSize: 11
                elide:          Text.ElideLeft
            }
        }
    }
}
