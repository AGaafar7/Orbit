//
//  AppDelegate.swift
//  Orbit
//
//  Created by Ahmed Gaafar on 25/03/2026.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as an accessory app (no Dock icon, no Menu Bar by default)
        NSApp.setActivationPolicy(.accessory)
        setupMenuBar()

        
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
    
    private func setupMenuBar() {
           statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
           
           if let button = statusItem?.button {
               button.image = NSImage(systemSymbolName: "circle.circle", accessibilityDescription: "Orbit")
           }
           
           let menu = NSMenu()
           
           let titleItem = NSMenuItem(title: "Orbit is Active", action: nil, keyEquivalent: "")
           titleItem.isEnabled = false
           menu.addItem(titleItem)
           
           menu.addItem(NSMenuItem.separator())
           
           let quitItem = NSMenuItem(title: "Quit Orbit", action: #selector(quitApp), keyEquivalent: "q")
           menu.addItem(quitItem)
           
           statusItem?.menu = menu
       }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    private func promptForAccessibility() {
            NSApp.setActivationPolicy(.regular)
            
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "Orbit needs Accessibility permissions to detect the Option+Tab shortcut and switch apps.\n\nPlease grant it in System Settings > Privacy & Security > Accessibility, then relaunch Orbit."
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Quit")
                
                NSApp.activate(ignoringOtherApps: true)
                
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
                NSApp.terminate(nil)
            }
        }
}
