// Kanagawa colour palette — mirrors themes/kanagawa.css from the waybar config.
pragma Singleton
import QtQuick

QtObject {
    // ── Base ────────────────────────────────────────────────────────────────
    readonly property color base:   "#1f1f28"
    readonly property color mantle: "#16161d"
    readonly property color crust:  "#0d0d14"

    // ── Text ────────────────────────────────────────────────────────────────
    readonly property color text:     "#dcd7ba"
    readonly property color subtext0: "#a89984"
    readonly property color subtext1: "#c8c093"

    // ── Surface ─────────────────────────────────────────────────────────────
    readonly property color surface0: "#2a2a37"
    readonly property color surface1: "#363646"
    readonly property color surface2: "#43436f"

    // ── Overlay ─────────────────────────────────────────────────────────────
    readonly property color overlay0: "#565575"
    readonly property color overlay1: "#727169"
    readonly property color overlay2: "#8b8b8b"

    // ── Accent ──────────────────────────────────────────────────────────────
    readonly property color blue:      "#7aa89f"
    readonly property color lavender:  "#a4b9ef"
    readonly property color sapphire:  "#7fb4ca"
    readonly property color sky:       "#7dc4e4"
    readonly property color teal:      "#6a9589"
    readonly property color green:     "#76946a"
    readonly property color yellow:    "#dca561"
    readonly property color peach:     "#ffa066"
    readonly property color maroon:    "#e46876"
    readonly property color red:       "#e82424"
    readonly property color mauve:     "#957fb8"
    readonly property color pink:      "#d27e99"
    readonly property color flamingo:  "#e82424"
    readonly property color rosewater: "#dcd7ba"

    // ── Semantic helpers ─────────────────────────────────────────────────────
    readonly property color backgroundPrimary:   "#1f1f28"
    readonly property color backgroundSecondary: "#2a2a37"
    readonly property color backgroundHover:     "#363646"
    readonly property color borderColor:         "#565575"

    readonly property color success: "#76946a"
    readonly property color warning: "#dca561"
    readonly property color error:   "#e82424"
    readonly property color info:    "#7aa89f"

    // ── Bar chrome ───────────────────────────────────────────────────────────
    // rgba(15, 15, 20, 0.94) → same as waybar window#waybar background
    readonly property color barBackground: Qt.rgba(0.059, 0.059, 0.078, 0.94)
    // rgba(149, 127, 184, 0.3) → same as waybar border-bottom
    readonly property color barBorder:     Qt.rgba(0.584, 0.498, 0.722, 0.3)
}
