//
//  AppDelegate.swift
//  Orbit
//
//  Created by Ahmed Gaafar on 25/03/2026.
//


// AppDelegate.swift
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as an accessory app (no Dock icon, no Menu Bar by default)
        NSApp.setActivationPolicy(.accessory)
        
        // Check for Accessibility Permissions
        if checkAccessibility() {
            OrbitInputManager.shared.startMonitoring()
        } else {
            promptForAccessibility()
        }
    }
    
    private func checkAccessibility() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
    
    private func promptForAccessibility() {
            // Temporarily make it a regular app so the alert is forced to the front
            NSApp.setActivationPolicy(.regular)
            
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "Orbit needs Accessibility permissions to detect the Option+Tab shortcut and switch apps.\n\nPlease grant it in System Settings > Privacy & Security > Accessibility, then relaunch Orbit."
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Quit")
                
                // Force the app to the front
                NSApp.activate(ignoringOtherApps: true)
                
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
                // Terminate so the user can relaunch after granting permission
                NSApp.terminate(nil)
            }
        }
}
