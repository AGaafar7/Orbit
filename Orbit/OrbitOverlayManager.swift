//
//  OrbitOverlayManager.swift
//  Orbit
//
//  Created by Ahmed Gaafar on 25/03/2026.
//


import Cocoa
import SwiftUI
import Combine
class OrbitWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
}

class OrbitOverlayManager: ObservableObject {
    static let shared = OrbitOverlayManager()
    
    @Published var apps:[OrbitAppInfo] = []
    @Published var selectedIndex: Int = 0
    @Published var isVisible: Bool = false
    
    private var overlayWindow: OrbitWindow?
    
    private lazy var helperWindow: OrbitWindow = {
        let win = OrbitWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        win.alphaValue = 0.01
        win.level = .screenSaver
        win.isReleasedWhenClosed = false
        return win
    }()
    
    func showOverlay() {
        apps = OrbitAppFetcher.fetchRunningApps()
        selectedIndex = 0
        
        if overlayWindow == nil {
            let view = OrbitSwitcherView().environmentObject(self)
            let hostingController = NSHostingController(rootView: view)
            
            let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
            
            let win = OrbitWindow(
                contentRect: screenRect,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            win.isOpaque = false
            win.backgroundColor = .clear
            win.hasShadow = false
            win.level = .screenSaver
            win.collectionBehavior = [.canJoinAllSpaces, .ignoresCycle, .stationary]
            
            hostingController.view.frame = NSRect(origin: .zero, size: screenRect.size)
            hostingController.view.autoresizingMask = [.width, .height]
            
            win.contentViewController = hostingController
            win.isReleasedWhenClosed = false
            overlayWindow = win
        } else {
            if let screenRect = NSScreen.main?.frame {
                overlayWindow?.setFrame(screenRect, display: true)
            }
        }
        
        overlayWindow?.makeKeyAndOrderFront(nil)
        isVisible = true
    }
    
    func hideOverlay() {
        overlayWindow?.orderOut(nil)
        isVisible = false
    }
    
    func cycle(forward: Bool) {
        if apps.isEmpty { return }
        if forward {
            selectedIndex = (selectedIndex + 1) % apps.count
        } else {
            selectedIndex = (selectedIndex - 1 + apps.count) % apps.count
        }
    }
    
    func activateSelectedApp() {
        guard !apps.isEmpty, apps.indices.contains(selectedIndex) else {
            hideOverlay()
            return
        }
        
        let targetApp = apps[selectedIndex].runningApp
        hideOverlay()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.helperWindow.makeKeyAndOrderFront(nil)
            NSRunningApplication.current.activate(options: [.activateAllWindows])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                targetApp.activate(options: [.activateAllWindows])
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.helperWindow.orderOut(nil)
                }
            }
        }
    }
}
