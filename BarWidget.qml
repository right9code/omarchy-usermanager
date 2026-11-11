import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Optional bar widget; visibility driven by state file (toggled from menu)
Item {
  id: root
  readonly property string homeDir: Quickshell.env("HOME") || ""
  readonly property string stateFile: homeDir + "/.local/state/omarchy/usermanager/bar-enabled"
  property bool enabled: false

  implicitWidth: enabled ? 28 : 0
  implicitHeight: 28
  visible: enabled

  // Probe state
  Process {
    id: probe
    command: ["bash", "-c", "[[ -f '" + root.stateFile + "' ]] && cat '" + root.stateFile + "' || echo disabled"]
    stdout: SplitParser {
      onRead: function(line) { root.enabled = (String(line).trim() === "enabled") }
    }
  }
  FileView { path: root.homeDir + "/.local/state/omarchy/usermanager"; watchChanges: true; printErrors: false; onFileChanged: probe.running = true }

  Component.onCompleted: probe.running = true

  // Icon
  Text {
    anchors.centerIn: parent
    text: "󰀉"
    color: "#cdd6f4"
    font.pixelSize: 16
  }

  MouseArea {
    anchors.fill: parent
    onClicked: launch.running = true
    cursorShape: Qt.PointingHandCursor
  }

  Process {
    id: launch
    command: ["omarchy-launch-tui", "--app-id=org.omarchy.usermanager", "usermgr"]
  }
}
