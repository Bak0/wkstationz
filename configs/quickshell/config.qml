import QtQuick
import Quickshell

// Main Quickshell configuration
// Loads all components

ShellRoot {
    id: root
    
    // Load theme
    property var theme: ThemeLoader.theme
    
    // Load bar
    Bar {}
    
    // Load lock screen
    LockScreen {}
}
