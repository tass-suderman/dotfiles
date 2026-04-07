// Entry point – spawn one Bar per connected screen, plus a single global
// launcher popup and IPC handler for keybinding integration.
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    // One bar per monitor
    Variants {
        model: Quickshell.screens

        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }

    // Single global launcher popup (not per-monitor)
    LauncherPopup {}

    // IPC endpoint – called by launcher.sh via `quickshell ipc call launcher open <mode>`
    IpcHandler {
        target: "launcher"

        function open(mode: string): void {
            LauncherService.open(mode)
        }

        function close(): void {
            LauncherService.close()
        }
    }
}
