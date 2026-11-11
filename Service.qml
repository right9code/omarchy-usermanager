import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  readonly property string homeDir: Quickshell.env("HOME") || ""
  readonly property string stateDir: homeDir + "/.local/state/omarchy/usermanager"
  readonly property string stateFile: stateDir + "/bar-enabled"

  // Ensure state dir exists
  Component.onCompleted: {
    mkDir.running = true
    probe.running = true
  }

  Process { id: mkDir; command: ["bash", "-c", "mkdir -p '" + root.stateDir + "'"] }

  // Probe whether bar widget is enabled
  Process {
    id: probe
    command: ["bash", "-c", "[[ -f '" + root.stateFile + "' ]] && cat '" + root.stateFile + "' || echo disabled"]
    stdout: SplitParser {
      onRead: function(line) {
        barEnabled = (String(line).trim() === "enabled")
      }
    }
  }

  property bool barEnabled: false

  // Watch state dir for changes
  FileView {
    path: root.stateDir
    watchChanges: true
    printErrors: false
    onFileChanged: probe.running = true
  }
}
